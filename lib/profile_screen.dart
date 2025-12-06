import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_state.dart';
import 'theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Card(
              color: AppTheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    gameState.photoUrl != null && gameState.photoUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              gameState.photoUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => CircleAvatar(
                                radius: 40,
                                backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
                                child: Text(
                                  (gameState.username ?? 'U')[0].toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryYellow,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.primaryYellow.withOpacity(0.2),
                            child: Text(
                              (gameState.username ?? 'U')[0].toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryYellow,
                              ),
                            ),
                          ),
                    const SizedBox(height: 16),
                    Text(
                      gameState.username ?? 'User',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      gameState.email ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Gold Balance
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: AppTheme.primaryYellow,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${gameState.gold} G',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stats Section
            Card(
              color: AppTheme.surface,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.assignment, color: AppTheme.primaryYellow),
                    title: Text(
                      'Total Tasks',
                      style: GoogleFonts.inter(color: AppTheme.textPrimary),
                    ),
                    trailing: Text(
                      '${gameState.tasks.length}',
                      style: GoogleFonts.inter(
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.check_circle, color: AppTheme.success),
                    title: Text(
                      'Completed',
                      style: GoogleFonts.inter(color: AppTheme.textPrimary),
                    ),
                    trailing: Text(
                      '${gameState.tasks.where((t) => t.isCompleted).length}',
                      style: GoogleFonts.inter(
                        color: AppTheme.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.pending, color: AppTheme.textSecondary),
                    title: Text(
                      'Pending',
                      style: GoogleFonts.inter(color: AppTheme.textPrimary),
                    ),
                    trailing: Text(
                      '${gameState.tasks.where((t) => !t.isCompleted).length}',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings Section
            Card(
              color: AppTheme.surface,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: AppTheme.primaryYellow),
                    title: Text(
                      'Settings',
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                    onTap: () => _showSettingsDialog(context, gameState),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.history, color: AppTheme.textSecondary),
                    title: Text(
                      'Task History',
                      style: GoogleFonts.inter(color: AppTheme.textPrimary),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Task history coming soon!')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppTheme.danger),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.inter(color: AppTheme.danger),
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: AppTheme.surface,
                          title: Text(
                            'Logout',
                            style: GoogleFonts.inter(color: AppTheme.textPrimary),
                          ),
                          content: Text(
                            'Are you sure you want to logout?',
                            style: GoogleFonts.inter(color: AppTheme.textSecondary),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(color: AppTheme.textSecondary),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.danger,
                              ),
                              child: Text(
                                'Logout',
                                style: GoogleFonts.inter(color: AppTheme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await gameState.logout();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, GameState gameState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Settings',
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: AppTheme.primaryYellow),
                title: Text(
                  'Username',
                  style: GoogleFonts.inter(color: AppTheme.textPrimary),
                ),
                subtitle: Text(
                  gameState.username ?? 'Not set',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onTap: () {
                  Navigator.pop(context);
                  _showEditUsernameDialog(context, gameState);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.email, color: AppTheme.primaryYellow),
                title: Text(
                  'Email',
                  style: GoogleFonts.inter(color: AppTheme.textPrimary),
                ),
                subtitle: Text(
                  gameState.email ?? 'Not set',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onTap: () {
                  Navigator.pop(context);
                  _showEditEmailDialog(context, gameState);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo, color: AppTheme.primaryYellow),
                title: Text(
                  'Profile Photo',
                  style: GoogleFonts.inter(color: AppTheme.textPrimary),
                ),
                subtitle: Text(
                  gameState.photoUrl != null ? 'Photo set' : 'No photo',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary),
                ),
                trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                onTap: () {
                  Navigator.pop(context);
                  _showEditPhotoDialog(context, gameState);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUsernameDialog(BuildContext context, GameState gameState) {
    final TextEditingController controller = TextEditingController(text: gameState.username ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Edit Username',
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter new username',
            hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Username cannot be empty'),
                    backgroundColor: AppTheme.danger,
                  ),
                );
                return;
              }

              final error = await gameState.updateUsername(controller.text.trim());
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: AppTheme.danger,
                  ),
                );
              } else if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Username updated successfully!'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryYellow),
            child: Text(
              'Save',
              style: GoogleFonts.inter(color: AppTheme.background),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditEmailDialog(BuildContext context, GameState gameState) {
    final TextEditingController controller = TextEditingController(text: gameState.email ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Edit Email',
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Enter new email',
                hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Note: You may need to logout and login again to change your email.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty || !controller.text.trim().contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid email address'),
                    backgroundColor: AppTheme.danger,
                  ),
                );
                return;
              }

              final error = await gameState.updateEmail(controller.text.trim());
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: AppTheme.danger,
                  ),
                );
              } else if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Email updated successfully!'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryYellow),
            child: Text(
              'Save',
              style: GoogleFonts.inter(color: AppTheme.background),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPhotoDialog(BuildContext context, GameState gameState) {
    final TextEditingController controller = TextEditingController(text: gameState.photoUrl ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Edit Profile Photo',
          style: GoogleFonts.inter(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              style: GoogleFonts.inter(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Paste photo URL (e.g., imgur, imgbb)',
                hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                filled: true,
                fillColor: AppTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.image, color: AppTheme.primaryYellow),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: Upload your photo to imgur.com or imgbb.com and paste the image URL here.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (gameState.photoUrl != null) ...[
              const SizedBox(height: 16),
              Text(
                'Current Photo:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  gameState.photoUrl!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: AppTheme.surface,
                    child: const Icon(Icons.error, color: AppTheme.danger),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (gameState.photoUrl != null)
            TextButton(
              onPressed: () async {
                final error = await gameState.updatePhotoUrl(null);
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: AppTheme.danger,
                    ),
                  );
                } else if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Photo removed successfully!'),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
              child: Text(
                'Remove Photo',
                style: GoogleFonts.inter(color: AppTheme.danger),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final photoUrl = controller.text.trim();
              final error = await gameState.updatePhotoUrl(photoUrl.isEmpty ? null : photoUrl);
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: AppTheme.danger,
                  ),
                );
              } else if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Photo updated successfully!'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryYellow),
            child: Text(
              'Save',
              style: GoogleFonts.inter(color: AppTheme.background),
            ),
          ),
        ],
      ),
    );
  }
}

