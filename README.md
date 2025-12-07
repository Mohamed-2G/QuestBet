# QuestBet 🎯

A gamified productivity app that turns your goals into quests. Complete tasks, earn gold, and compete with friends!

![QuestBet](https://img.shields.io/badge/QuestBet-v1.0.0-yellow)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)
![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange)

##Features

###Gamified Task Management
- Quest Creation: Create tasks (quests) with a mandatory 50 gold fee
- Rewards System: Earn 80 gold upon completing a quest
- Gold Economy: Start with 350 gold, manage your balance strategically
- Proof System: Upload images, links, or files as proof of completion

### 👥 Social Features
- Groups (Clans): Create or join groups with unique codes
- Leaderboards: Compete globally or within your group
- Two Leaderboard Types: 
  - Most Coins (Gold)
  - Most Completed Tasks

###Modern UI/UX
- QuestBet Theme**: Vibrant yellow color scheme with energetic design
- Quest-Based Language**: Tasks are called "quests" for immersive experience
- Quick-Pick Templates**: Fast task creation with preset categories
- Focus Mode**: Distraction-free timer for completing quests

###User Management
- Authentication: Secure login/registration with Firebase
- Profile Management: Customize username, email, and profile photo
- Auto-Login: Seamless authentication state persistence

##Getting Started

###Prerequisites
- Flutter SDK (>=3.0.0)
- Firebase project set up
- Android Studio / VS Code with Flutter extensions

###Installation

1.Clone the repository
   ```bash
   git clone https://github.com/yourusername/questbet.git
   cd questbet
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Firebase Setup
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Enable Firestore Database
   - Add your app to Firebase and download `google-services.json` (Android) or configure iOS
   - Run `flutterfire configure` to generate `firebase_options.dart`
   - Update Firestore security rules (see `firestore.rules` file)

4. Configure Firestore Rules
   - Go to Firebase Console → Firestore Database → Rules
   - Copy the rules from `firestore.rules` file
   - Publish the rules

5. Run the app
   ```bash
   flutter run
   ```

##Screenshots

*Add screenshots of your app here*

##Project Structure


##Core Mechanics

###Quest Creation
- Cost: 50 gold (mandatory)
- Reward: 80 gold upon completion
- Net Profit: +30 gold per completed quest

###Gold System
- Starting Gold: 350 gold for new accounts
- **Quest Creation Fee: 50 gold (deducted immediately)
- Completion Reward: 80 gold (added when quest is completed)
- Failed Quests: Gold is forfeited if deadline is missed

###Groups
- Create groups with custom names
- Join groups using 6-character codes
- View group members and their gold balances
- Compete in group-specific leaderboards

##Configuration

###Firebase Setup
1. Create a Firebase project
2. Enable Email/Password authentication
3. Create Firestore database
4. Configure security rules (see `firestore.rules`)
5. Add platform-specific configuration files

###Environment Variables
No environment variables required. All configuration is handled through Firebase.

##Dependencies

- `provider` - State management
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Database
- `firebase_auth` - Authentication
- `google_fonts` - Typography (Poppins)
- `image_picker` - Camera/gallery access
- `file_picker` - File selection
- `intl` - Date/time formatting

##Development

###Running Tests
```bash
flutter test
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

##License

This project is licensed under the MIT License - see the LICENSE file for details.

##Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

##Author

Your Name
- GitHub: [@yourusername](https://github.com/yourusername)

##Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Google Fonts for Poppins typography

---

This code was generated using Flutter.
