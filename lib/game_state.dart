import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' hide Task;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'task_model.dart' show Task;

class GameState extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // Optional: Set via --dart-define=IMGBB_API_KEY=your_key
  static const String _imgbbApiKey = String.fromEnvironment('IMGBB_API_KEY', defaultValue: '');

  int _gold = 0;
  String? _username;
  String? _email;
  String? _photoUrl;
  String? _avatarAsset; // local asset path for equipped avatar
  String? _groupCode;
  String? _groupName;
  List<Task> _tasks = [];
  List<Task> _completedTasksHistory = [];
  bool isLoading = false;
  List<Map<String, dynamic>> _groupMembers = [];
  int? _debugCompletedOverride; // debug-only override for testing avatars

  int get gold => _gold;
  String? get username => _username;
  String? get email => _email;
  String? get photoUrl => _photoUrl;
  String? get avatarAsset => _avatarAsset;
  String? get groupCode => _groupCode;
  String? get groupName => _groupName;
  List<Task> get tasks => _tasks;
  List<Task> get completedTasksHistory => _completedTasksHistory;
  List<Map<String, dynamic>> get groupMembers => _groupMembers;

  // Leaderboard data
  List<Map<String, dynamic>> _globalCoinsLeaderboard = [];
  List<Map<String, dynamic>> _globalTasksLeaderboard = [];
  List<Map<String, dynamic>> _groupCoinsLeaderboard = [];
  List<Map<String, dynamic>> _groupTasksLeaderboard = [];

  List<Map<String, dynamic>> get globalCoinsLeaderboard => _globalCoinsLeaderboard;
  List<Map<String, dynamic>> get globalTasksLeaderboard => _globalTasksLeaderboard;
  List<Map<String, dynamic>> get groupCoinsLeaderboard => _groupCoinsLeaderboard;
  List<Map<String, dynamic>> get groupTasksLeaderboard => _groupTasksLeaderboard;

  // Constructor - Check for existing auth state
  GameState() {
    _checkAuthState();
  }

  // Check if user is already logged in (on app startup)
  Future<void> _checkAuthState() async {
    try {
      isLoading = true;
      notifyListeners();

      User? currentUser = _auth.currentUser;
      
      if (currentUser != null) {
        // User is already logged in, load their data
        // User is already logged in, load their data
        String uid = currentUser.uid;
        
        DocumentSnapshot doc = await _db.collection('players').doc(uid).get();
        
        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _username = data['username'];
          _email = data['email'];
          _photoUrl = data['photoUrl'];
          _gold = data['gold'] ?? 0;
          _groupCode = data['groupCode'];
          _avatarAsset = data['avatarAsset'];
          await _loadTasks();
          if (_groupCode != null && _groupCode!.isNotEmpty) {
            await _loadGroupMembers();
          }
          // Auto-login successful
        }
      }
    } catch (e) {
      debugPrint("Auth state check error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 1. REGISTER (New Account)
  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();
      
      String cleanUsername = username.trim().toLowerCase();

      // A. Check if username is already taken in Firestore
      final usernameCheck = await _db
          .collection('players')
          .where('username', isEqualTo: cleanUsername)
          .get();

      if (usernameCheck.docs.isNotEmpty) {
        return "Username '$cleanUsername' is already taken!";
      }

      // B. Create Secure Account in Firebase Auth
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // C. Create Player Profile in Firestore
      String uid = userCred.user!.uid;
      
      await _db.collection('players').doc(uid).set({
        'username': cleanUsername,
        'email': email.trim(),
        'gold': 350, 
        'createdAt': FieldValue.serverTimestamp(),
      });

      // D. Initialize Local State
      _username = cleanUsername;
      _email = email.trim();
      _gold = 350;
      _groupCode = null;
      await _loadTasks();
      
      return null; // Success!
      
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase auth error: ${e.code}");
      
      // Return user-friendly error messages
      if (e.code == 'weak-password') {
        return 'Password is too weak (min 6 characters)';
      } else if (e.code == 'email-already-in-use') {
        return 'This email is already registered';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      } else if (e.code == 'operation-not-allowed') {
        return 'Email/password accounts are not enabled';
      }
      return e.message ?? 'Registration failed';
      
    } catch (e) {
      debugPrint("Registration error: $e");
      return "Registration failed: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 2. LOGIN (Username OR Email) - FIXED VERSION
  Future<String?> login({
    required String loginInput, 
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      // Starting login process

      String emailToUse = loginInput.trim();

      // A. DETECT: Is this a Username? (No '@' symbol)
      if (!loginInput.contains('@')) {
        // Username detected, looking up email
        
        String cleanUsername = loginInput.trim().toLowerCase();

        final query = await _db
            .collection('players')
            .where('username', isEqualTo: cleanUsername)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          return "Username '$cleanUsername' not found!";
        }
        
        Map<String, dynamic> userData = query.docs.first.data();
        String? foundEmail = userData['email'] as String?;
        
        if (foundEmail == null || foundEmail.isEmpty) {
          return "User profile is missing email. Please contact support.";
        }
        
        emailToUse = foundEmail;
        // Email found for username
      }

      // B. Login using Email & Password
      // Signing in with Firebase Auth
      
      // FIX: Wrap in try-catch to handle the pigeon error
      UserCredential? userCred;
      try {
        userCred = await _auth.signInWithEmailAndPassword(
          email: emailToUse,
          password: password,
        );
      } catch (authError) {
        debugPrint("Auth error details: $authError");
        // Re-throw to be caught by outer catch block
        rethrow;
      }

      if (userCred.user == null) {
        return "Login failed - no user returned";
      }

      // C. Load Player Data from Firestore
      // Loading user profile
      String uid = userCred.user!.uid;
      String authEmail = userCred.user!.email ?? emailToUse;
      
      DocumentSnapshot doc = await _db.collection('players').doc(uid).get();

      // If document doesn't exist, create it (fallback for users created manually in Firebase Console)
      if (!doc.exists) {
        // Player profile not found, creating one
        
        // Generate username from email (part before @)
        String generatedUsername = authEmail.split('@')[0].toLowerCase();
        
        // Check if this username is already taken
        final usernameCheck = await _db
            .collection('players')
            .where('username', isEqualTo: generatedUsername)
            .get();
        
        // If taken, append a number
        if (usernameCheck.docs.isNotEmpty) {
          int counter = 1;
          String baseUsername = generatedUsername;
          while (true) {
            generatedUsername = '$baseUsername$counter';
            final check = await _db
                .collection('players')
                .where('username', isEqualTo: generatedUsername)
                .get();
            if (check.docs.isEmpty) break;
            counter++;
          }
        }
        
        // Create the player document
        await _db.collection('players').doc(uid).set({
          'username': generatedUsername,
          'email': authEmail,
          'gold': 350, // Starting gold
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Created player profile
        
        _username = generatedUsername;
        _email = authEmail;
        _gold = 350;
        _groupCode = null;
      } else {
        // Document exists, load the data
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        
        if (data == null) {
          return "Player profile data is corrupted. Please contact support.";
        }
        
        String? username = data['username'] as String?;
        String? email = data['email'] as String?;
        
        if (username == null || username.isEmpty) {
          // If username is missing, generate one from email
          String generatedUsername = (email ?? authEmail).split('@')[0].toLowerCase();
          await _db.collection('players').doc(uid).update({'username': generatedUsername});
          username = generatedUsername;
        }
        
        if (email == null || email.isEmpty) {
          // If email is missing, use the auth email
          await _db.collection('players').doc(uid).update({'email': authEmail});
          email = authEmail;
        }
        
        _username = username;
        _email = email;
        _photoUrl = data['photoUrl'];
        _gold = (data['gold'] as int?) ?? 0;
        _groupCode = data['groupCode'];
        _avatarAsset = data['avatarAsset'];
        
        if (_groupCode != null && _groupCode!.isNotEmpty) {
          await _loadGroupMembers();
        }
      }
      
      try {
        await _loadTasks();
      } catch (e) {
        debugPrint("Warning: Could not load tasks: $e");
        // Continue anyway - tasks can be empty
      }
      
      // Login successful
      return null; // Success!

    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase auth error: ${e.code}");
      
      // Return user-friendly error messages
      if (e.code == 'user-not-found') {
        return 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password';
      } else if (e.code == 'invalid-credential') {
        return 'Invalid email or password';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format';
      } else if (e.code == 'user-disabled') {
        return 'This account has been disabled';
      } else if (e.code == 'too-many-requests') {
        return 'Too many failed attempts. Try again later';
      }
      return e.message ?? 'Login failed';
      
    } catch (e) {
      debugPrint("Login error: $e (${e.runtimeType})");
      if (e is FirebaseAuthException) {
        // This shouldn't happen as we catch it above, but just in case
        return e.message ?? 'Login failed';
      }
      return "Login failed: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 3. LOGOUT
  Future<void> logout() async {
    await _auth.signOut(); 
    _username = null;
    _email = null;
    _photoUrl = null;
    _gold = 0;
    _tasks = [];
    _groupCode = null;
    _groupName = null;
    _groupMembers = [];
    notifyListeners();
  }

  // 10. UPDATE USERNAME
  Future<String?> updateUsername(String newUsername) async {
    User? user = _auth.currentUser;
    if (user == null) return "Not logged in";

    try {
      String cleanUsername = newUsername.trim().toLowerCase();
      
      if (cleanUsername.isEmpty) {
        return "Username cannot be empty";
      }

      // Check if username is already taken (by another user)
      final usernameCheck = await _db
          .collection('players')
          .where('username', isEqualTo: cleanUsername)
          .get();

      // If username is taken by someone else, return error
      if (usernameCheck.docs.isNotEmpty && usernameCheck.docs.first.id != user.uid) {
        return "Username '$cleanUsername' is already taken!";
      }

      // Update in Firestore
      await _db.collection('players').doc(user.uid).update({
        'username': cleanUsername,
      });

      _username = cleanUsername;
      notifyListeners();
      return null; // Success
    } catch (e) {
      return "Failed to update username: ${e.toString()}";
    }
  }

  // 11. UPDATE EMAIL
  Future<String?> updateEmail(String newEmail) async {
    User? user = _auth.currentUser;
    if (user == null) return "Not logged in";

    try {
      String cleanEmail = newEmail.trim().toLowerCase();
      
      if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
        return "Invalid email address";
      }

      // Update Firebase Auth email
      await user.updateEmail(cleanEmail);
      
      // Update in Firestore
      await _db.collection('players').doc(user.uid).update({
        'email': cleanEmail,
      });

      _email = cleanEmail;
      notifyListeners();
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return "Please logout and login again to change your email";
      }
      return "Failed to update email: ${e.message}";
    } catch (e) {
      return "Failed to update email: ${e.toString()}";
    }
  }

  // 12. UPDATE PHOTO URL (from File upload)
  Future<String?> updatePhotoFromFile(File imageFile) async {
    User? user = _auth.currentUser;
    if (user == null) return "Not logged in";

    try {
      isLoading = true;
      notifyListeners();

      // Prefer free imgbb upload when API key provided
      if (_imgbbApiKey.isNotEmpty) {
        try {
          final bytes = await imageFile.readAsBytes();
          final base64Image = base64Encode(bytes);
          final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$_imgbbApiKey');
          final response = await http.post(
            uri,
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: { 'image': base64Image },
          );
          final Map<String, dynamic> jsonResp = jsonDecode(response.body) as Map<String, dynamic>;
          if (response.statusCode == 200 && (jsonResp['success'] == true)) {
            final data = jsonResp['data'] as Map<String, dynamic>;
            final String downloadUrl = (data['url'] as String?) ?? (data['display_url'] as String? ?? '');
            if (downloadUrl.isEmpty) throw Exception('Upload succeeded but URL missing');

            await _db.collection('players').doc(user.uid).update({ 'photoUrl': downloadUrl });
            _photoUrl = downloadUrl;
            isLoading = false;
            notifyListeners();
            return null;
          } else {
            // Fall through to Firebase Storage if imgbb fails
            debugPrint('imgbb upload failed: ${response.statusCode} ${response.body}');
          }
        } catch (e) {
          debugPrint('imgbb upload error: $e');
          // fall back to Firebase Storage
        }
      }

      // Upload image to Firebase Storage
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage
          .ref()
          .child('profile_photos')
          .child(user.uid)
          .child(fileName);

      // Ensure correct content type and wait for completion snapshot
      final UploadTask uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      // Use the snapshot's ref to get a download URL (avoids ref mismatch)
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update in Firestore
      await _db.collection('players').doc(user.uid).update({
        'photoUrl': downloadUrl,
      });

      _photoUrl = downloadUrl;
      isLoading = false;
      notifyListeners();
      return null; // Success
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return "Failed to upload photo: ${e.toString()}";
    }
  }

  // 12b. UPDATE PHOTO URL (from URL string - for backward compatibility)
  Future<String?> updatePhotoUrl(String? photoUrl) async {
    User? user = _auth.currentUser;
    if (user == null) return "Not logged in";

    try {
      String? cleanUrl = photoUrl?.trim();
      if (cleanUrl != null && cleanUrl.isEmpty) {
        cleanUrl = null;
      }

      // Update in Firestore
      Map<String, dynamic> updateData = {};
      if (cleanUrl == null) {
        updateData['photoUrl'] = FieldValue.delete();
      } else {
        updateData['photoUrl'] = cleanUrl;
      }
      
      await _db.collection('players').doc(user.uid).update(updateData);

      _photoUrl = cleanUrl;
      notifyListeners();
      return null; // Success
    } catch (e) {
      return "Failed to update photo: ${e.toString()}";
    }
  }

  // AVATARS: equip/clear an avatar asset stored locally under assets/avatars/
  Future<String?> setAvatarAsset(String? assetPath) async {
    User? user = _auth.currentUser;
    if (user == null) return "Not logged in";
    try {
      Map<String, dynamic> update = {};
      if (assetPath == null || assetPath.isEmpty) {
        update['avatarAsset'] = FieldValue.delete();
      } else {
        update['avatarAsset'] = assetPath;
      }
      await _db.collection('players').doc(user.uid).update(update);
      _avatarAsset = (assetPath == null || assetPath.isEmpty) ? null : assetPath;
      notifyListeners();
      return null;
    } catch (e) {
      return "Failed to update avatar: ${e.toString()}";
    }
  }

  // Number of completed tasks in local state
  int get completedTasksCount {
    if (kDebugMode && _debugCompletedOverride != null) return _debugCompletedOverride!;
    return _tasks.where((t) => t.isCompleted).length;
  }

  void setDebugCompletedOverride(int? value) {
    if (!kDebugMode) return; // no-op in release
    _debugCompletedOverride = value;
    notifyListeners();
  }

  // Thresholds that unlock avatars
  static const List<int> avatarThresholds = [
    100, 200, 300, 400, 500, 600, 800, 1000, 1200, 1500,
  ];

  // Return list of unlocked avatar asset paths given current progress
  List<String> getUnlockedAvatarAssets() {
    final int count = completedTasksCount;
    return avatarThresholds
        .where((t) => count >= t)
        .map((t) => 'assets/avatars/avatar_${t}.png')
        .toList();
  }

  // 12c. DELETE PHOTO
  Future<String?> deletePhoto() async {
    User? user = _auth.currentUser;
    if (user == null) return "Not logged in";

    try {
      // Delete from Firestore
      await _db.collection('players').doc(user.uid).update({
        'photoUrl': FieldValue.delete(),
      });

      // Optionally delete from Storage if it's a Firebase Storage URL
      if (_photoUrl != null && _photoUrl!.contains('firebasestorage.googleapis.com')) {
        try {
          final ref = _storage.refFromURL(_photoUrl!);
          await ref.delete();
        } catch (e) {
          // If deletion from storage fails, continue anyway
          debugPrint("Warning: Could not delete photo from storage: $e");
        }
      }

      _photoUrl = null;
      notifyListeners();
      return null; // Success
    } catch (e) {
      return "Failed to delete photo: ${e.toString()}";
    }
  }

  // 4. LOAD TASKS (with Lazy Check for missed deadlines)
  Future<void> _loadTasks() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _db
        .collection('players')
        .doc(user.uid)
        .collection('tasks')
        .get();

    _tasks = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      return Task(
        id: doc.id,
        title: data['title'],
        deadline: DateTime.parse(data['deadline']),
        isCompleted: data['isCompleted'] == true || data['isCompleted'] == 1,
        depositAmount: data['depositAmount'] ?? 50,
        proofLink: data['proofLink'],
        proofImageUrl: data['proofImageUrl'],
        completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null,
      );
    }).toList();

    // LAZY CHECK: Handle missed deadlines
    await _checkMissedDeadlines();
  }

  // Lazy Check - Punish users for missed deadlines
  Future<void> _checkMissedDeadlines() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DateTime now = DateTime.now();
    List<Task> failedTasks = [];

    for (Task task in _tasks) {
      if (task.deadline.isBefore(now) && !task.isCompleted) {
        // Mark as failed and burn the gold
        failedTasks.add(task);
        
        if (task.id != null) {
          await _db
              .collection('players')
              .doc(user.uid)
              .collection('tasks')
              .doc(task.id)
              .update({
            'isCompleted': false,
            'failed': true,
          });
        }

        // Burn the deposit (gold already deducted when task was created)
        // The gold is already gone, but we mark it as failed
      }
    }

    if (failedTasks.isNotEmpty) {
      notifyListeners();
      // Return failed tasks so UI can show popup
      return;
    }
  }

  // Get failed tasks for UI display
  List<Task> getFailedTasks() {
    return _tasks.where((Task task) => 
      task.deadline.isBefore(DateTime.now()) && !task.isCompleted
    ).toList();
  }

  // 7a. CREATE GROUP
  Future<String?> createGroup(String groupName) async {
    User? user = _auth.currentUser;
    if (user == null) return "Not logged in";

    if (groupName.trim().isEmpty) {
      return "Group name cannot be empty";
    }

    // Check if user is already in a group
    if (_groupCode != null && _groupCode!.isNotEmpty) {
      return "You are already in a group. Please leave your current group before creating a new one.";
    }

    // Double-check in Firestore to ensure user isn't in a group
    final userDoc = await _db.collection('players').doc(user.uid).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>?;
      final existingGroupCode = userData?['groupCode'] as String?;
      if (existingGroupCode != null && existingGroupCode.isNotEmpty) {
        _groupCode = existingGroupCode;
        await _loadGroupMembers();
        notifyListeners();
        return "You are already in a group. Please leave your current group before creating a new one.";
      }
    }

    try {
      // Generate a random 6-character group code
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      String groupCode = '';
      bool codeExists = true;
      int attempts = 0;
      
      // Keep generating until we find a unique code (max 10 attempts)
      final random = Random();
      while (codeExists && attempts < 10) {
        groupCode = '';
        for (int i = 0; i < 6; i++) {
          groupCode += chars[random.nextInt(chars.length)];
        }
        
        // Check if code already exists in groups collection
        final check = await _db
            .collection('groups')
            .doc(groupCode)
            .get();
        
        codeExists = check.exists;
        attempts++;
      }
      
      if (codeExists || groupCode.isEmpty) {
        return "Failed to generate unique group code. Please try again.";
      }
      
      // Create group document
      await _db.collection('groups').doc(groupCode).set({
        'name': groupName.trim(),
        'code': groupCode,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Update user's group code
      await _db.collection('players').doc(user.uid).update({
        'groupCode': groupCode,
      });

      _groupCode = groupCode;
      _groupName = groupName.trim();
      await _loadGroupMembers();
      notifyListeners();
      return null; // Success
    } catch (e) {
      return "Failed to create group: ${e.toString()}";
    }
  }

  // 7b. JOIN GROUP
  Future<String?> joinGroup(String code) async {
    User? user = _auth.currentUser;
    if (user == null) return "Not logged in";

    // Check if user is already in a group
    if (_groupCode != null && _groupCode!.isNotEmpty) {
      return "You are already in a group. Please leave your current group before joining another one.";
    }

    // Double-check in Firestore to ensure user isn't in a group
    final userDoc = await _db.collection('players').doc(user.uid).get();
    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>?;
      final existingGroupCode = userData?['groupCode'] as String?;
      if (existingGroupCode != null && existingGroupCode.isNotEmpty) {
        _groupCode = existingGroupCode;
        await _loadGroupMembers();
        notifyListeners();
        return "You are already in a group. Please leave your current group before joining another one.";
      }
    }

    try {
      String cleanCode = code.trim().toUpperCase();
      
      // Check if group exists
      final groupDoc = await _db.collection('groups').doc(cleanCode).get();
      if (!groupDoc.exists) {
        return "Group code not found. Please check the code and try again.";
      }
      
      // Update user's group code
      await _db.collection('players').doc(user.uid).update({
        'groupCode': cleanCode,
      });

      _groupCode = cleanCode;
      await _loadGroupMembers();
      notifyListeners();
      return null; // Success
    } catch (e) {
      return "Failed to join group: ${e.toString()}";
    }
  }

  // 8. LOAD GROUP MEMBERS
  Future<void> _loadGroupMembers() async {
    if (_groupCode == null || _groupCode!.isEmpty) {
      _groupMembers = [];
      _groupName = null;
      return;
    }

    try {
      // Load group info
      final groupDoc = await _db.collection('groups').doc(_groupCode).get();
      if (groupDoc.exists) {
        _groupName = groupDoc.data()?['name'];
      } else {
        _groupName = null;
      }

      // Load group members
      final snapshot = await _db
          .collection('players')
          .where('groupCode', isEqualTo: _groupCode)
          .get();

      _groupMembers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return {
          'uid': doc.id,
          'username': data['username'] ?? 'Unknown',
          'gold': data['gold'] ?? 0,
          'email': data['email'] ?? '',
        };
      }).toList();

      // Sort by gold (descending)
      _groupMembers.sort((a, b) => (b['gold'] as int).compareTo(a['gold'] as int));
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading group members: $e");
    }
  }

  // 9. LEAVE GROUP
  Future<void> leaveGroup() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('players').doc(user.uid).update({
      'groupCode': FieldValue.delete(),
    });

    _groupCode = null;
    _groupName = null;
    _groupMembers = [];
    _groupCoinsLeaderboard = [];
    _groupTasksLeaderboard = [];
    notifyListeners();
  }

  // 10. LOAD GLOBAL LEADERBOARD (Coins)
  Future<void> loadGlobalCoinsLeaderboard() async {
    try {
      final snapshot = await _db
          .collection('players')
          .orderBy('gold', descending: true)
          .limit(100)
          .get();

      _globalCoinsLeaderboard = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return {
          'uid': doc.id,
          'username': data['username'] ?? 'Unknown',
          'gold': data['gold'] ?? 0,
          'photoUrl': data['photoUrl'],
          'avatarAsset': data['avatarAsset'],
        };
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading global coins leaderboard: $e");
    }
  }

  // 11. LOAD GLOBAL LEADERBOARD (Completed Tasks)
  Future<void> loadGlobalTasksLeaderboard() async {
    try {
      final snapshot = await _db.collection('players').get();
      List<Map<String, dynamic>> playersWithTasks = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        
        // Count completed tasks
        final tasksSnapshot = await _db
            .collection('players')
            .doc(doc.id)
            .collection('tasks')
            .where('isCompleted', isEqualTo: true)
            .get();
        
        playersWithTasks.add({
          'uid': doc.id,
          'username': data['username'] ?? 'Unknown',
          'completedTasks': tasksSnapshot.docs.length,
          'photoUrl': data['photoUrl'],
          'avatarAsset': data['avatarAsset'],
        });
      }

      // Sort by completed tasks (descending)
      playersWithTasks.sort((a, b) => 
        (b['completedTasks'] as int).compareTo(a['completedTasks'] as int));
      
      _globalTasksLeaderboard = playersWithTasks.take(100).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading global tasks leaderboard: $e");
    }
  }

  // 12. LOAD GROUP LEADERBOARD (Coins)
  Future<void> loadGroupCoinsLeaderboard() async {
    if (_groupCode == null || _groupCode!.isEmpty) {
      _groupCoinsLeaderboard = [];
      return;
    }

    try {
      final snapshot = await _db
          .collection('players')
          .where('groupCode', isEqualTo: _groupCode)
          .get();

      _groupCoinsLeaderboard = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return {
          'uid': doc.id,
          'username': data['username'] ?? 'Unknown',
          'gold': data['gold'] ?? 0,
          'photoUrl': data['photoUrl'],
          'avatarAsset': data['avatarAsset'],
        };
      }).toList();

      // Sort by gold (descending)
      _groupCoinsLeaderboard.sort((a, b) => 
        (b['gold'] as int).compareTo(a['gold'] as int));
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading group coins leaderboard: $e");
    }
  }

  // 13. LOAD GROUP LEADERBOARD (Completed Tasks)
  Future<void> loadGroupTasksLeaderboard() async {
    if (_groupCode == null || _groupCode!.isEmpty) {
      _groupTasksLeaderboard = [];
      return;
    }

    try {
      final snapshot = await _db
          .collection('players')
          .where('groupCode', isEqualTo: _groupCode)
          .get();

      List<Map<String, dynamic>> membersWithTasks = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        
        // Count completed tasks
        final tasksSnapshot = await _db
            .collection('players')
            .doc(doc.id)
            .collection('tasks')
            .where('isCompleted', isEqualTo: true)
            .get();
        
        membersWithTasks.add({
          'uid': doc.id,
          'username': data['username'] ?? 'Unknown',
          'completedTasks': tasksSnapshot.docs.length,
          'photoUrl': data['photoUrl'],
          'avatarAsset': data['avatarAsset'],
        });
      }

      // Sort by completed tasks (descending)
      membersWithTasks.sort((a, b) => 
        (b['completedTasks'] as int).compareTo(a['completedTasks'] as int));
      
      _groupTasksLeaderboard = membersWithTasks;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading group tasks leaderboard: $e");
    }
  }

  // 5. ADD TASK
  Future<String?> addTask(String title, DateTime deadline) async {
    User? user = _auth.currentUser;
    if (user == null) return "Not logged in";

    const int taskCreationFee = 50; // Fixed fee for creating a task

    // Check if user has enough gold
    if (_gold < taskCreationFee) {
      return "Insufficient gold! You need 50 gold to create a task. You currently have $_gold gold.";
    }

    // Deduct the fee
    _gold -= taskCreationFee;
      await _db.collection('players').doc(user.uid).update({'gold': _gold});

    // Create the task with fixed deposit amount
      await _db.collection('players').doc(user.uid).collection('tasks').add({
        'title': title,
        'deadline': deadline.toIso8601String(),
        'isCompleted': false,
      'depositAmount': taskCreationFee,
      });

      await _loadTasks();
      notifyListeners();
    return null; // Success
  }

  // 6. COMPLETE TASK
  Future<void> completeTask(Task task, {String? proofLink, String? proofImageUrl}) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    if (!task.isCompleted) {
      final now = DateTime.now();
      Map<String, dynamic> updateData = {
        'isCompleted': true,
        'completedAt': now.toIso8601String(),
      };
      
      if (proofLink != null && proofLink.isNotEmpty) {
        updateData['proofLink'] = proofLink;
      }
      
      if (proofImageUrl != null && proofImageUrl.isNotEmpty) {
        updateData['proofImageUrl'] = proofImageUrl;
      }
      
      if (task.id != null) {
        await _db
            .collection('players')
            .doc(user.uid)
            .collection('tasks')
            .doc(task.id)
            .update(updateData);
      }

      _gold += 80;
      await _db.collection('players').doc(user.uid).update({'gold': _gold});
      await _loadTasks();
      notifyListeners();
    }
  }

  // 6b. UNCOMPLETE TASK (undo completion)
  Future<void> uncompleteTask(Task task) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    if (task.isCompleted && task.id != null) {
      await _db
          .collection('players')
          .doc(user.uid)
          .collection('tasks')
          .doc(task.id)
          .update({
        'isCompleted': false,
      });

      // Deduct the gold that was earned
      _gold = (_gold - 80).clamp(0, double.infinity).toInt();
      await _db.collection('players').doc(user.uid).update({'gold': _gold});
      await _loadTasks();
      notifyListeners();
    }
  }

  // 13. LOAD COMPLETED TASKS HISTORY (Past 30 days)
  Future<void> loadCompletedTasksHistory() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final snapshot = await _db
          .collection('players')
          .doc(user.uid)
          .collection('tasks')
          .where('isCompleted', isEqualTo: true)
          .where('completedAt', isGreaterThanOrEqualTo: thirtyDaysAgo.toIso8601String())
          .orderBy('completedAt', descending: true)
          .get();

      _completedTasksHistory = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Task(
          id: doc.id,
          title: data['title'],
          deadline: DateTime.parse(data['deadline']),
          isCompleted: true,
          depositAmount: data['depositAmount'] ?? 50,
          proofLink: data['proofLink'],
          proofImageUrl: data['proofImageUrl'],
          completedAt: data['completedAt'] != null ? DateTime.parse(data['completedAt']) : null,
        );
      }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Error loading completed tasks history: $e");
      // If query fails (maybe completedAt field doesn't exist or index missing), try without it
      try {
        final snapshot = await _db
            .collection('players')
            .doc(user.uid)
            .collection('tasks')
            .where('isCompleted', isEqualTo: true)
            .get();

        _completedTasksHistory = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          final completedAt = data['completedAt'] != null 
              ? DateTime.parse(data['completedAt'])
              : null;
          
          // Only include tasks completed in the last 30 days
          if (completedAt != null && completedAt.isAfter(DateTime.now().subtract(const Duration(days: 30)))) {
            return Task(
              id: doc.id,
              title: data['title'],
              deadline: DateTime.parse(data['deadline']),
              isCompleted: true,
              depositAmount: data['depositAmount'] ?? 50,
              proofLink: data['proofLink'],
              proofImageUrl: data['proofImageUrl'],
              completedAt: completedAt,
            );
          }
          return null;
        }).whereType<Task>().toList();

        // Sort by completedAt descending
        _completedTasksHistory.sort((Task a, Task b) {
          if (a.completedAt == null && b.completedAt == null) return 0;
          if (a.completedAt == null) return 1;
          if (b.completedAt == null) return -1;
          return b.completedAt!.compareTo(a.completedAt!);
        });

        notifyListeners();
      } catch (e2) {
        debugPrint("Error loading completed tasks history (fallback): $e2");
        _completedTasksHistory = [];
        notifyListeners();
      }
    }
  }
}