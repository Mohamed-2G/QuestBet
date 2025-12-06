import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_state.dart';
import 'login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'leaderboard_screen.dart';
import 'groups_screen.dart';
import 'profile_screen.dart';
import 'workspace_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => GameState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuestBet',
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    // 1. Loading Spinner
    if (gameState.isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow)),
      );
    }

    // 2. Login Screen (If no username found)
    if (gameState.username == null || gameState.username!.isEmpty) {
      return const LoginScreen();
    }

    // 3. Main Navigation (If username exists)
    return const MainNavigation();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const WorkspaceScreen(),
    const LeaderboardScreen(),
    const GroupsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          boxShadow: AppTheme.elevatedShadow,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.primaryYellow,
            unselectedItemColor: AppTheme.textTertiary,
            selectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: _currentIndex == 0 
                        ? AppTheme.yellowGradient
                        : null,
                    color: _currentIndex == 0 
                        ? null
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 0 ? Icons.work : Icons.work_outline,
                    size: 24,
                    color: _currentIndex == 0
                        ? AppTheme.textPrimary
                        : AppTheme.textTertiary,
                  ),
                ),
                label: 'Workspace',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: _currentIndex == 1 
                        ? AppTheme.yellowGradient
                        : null,
                    color: _currentIndex == 1 
                        ? null
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 1 ? Icons.emoji_events : Icons.emoji_events_outlined,
                    size: 24,
                    color: _currentIndex == 1
                        ? AppTheme.textPrimary
                        : AppTheme.textTertiary,
                  ),
                ),
                label: 'Leaderboard',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: _currentIndex == 2 
                        ? AppTheme.yellowGradient
                        : null,
                    color: _currentIndex == 2 
                        ? null
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 2 ? Icons.group : Icons.group_outlined,
                    size: 24,
                    color: _currentIndex == 2
                        ? AppTheme.textPrimary
                        : AppTheme.textTertiary,
                  ),
                ),
                label: 'Groups',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: _currentIndex == 3 
                        ? AppTheme.yellowGradient
                        : null,
                    color: _currentIndex == 3 
                        ? null
                        : Colors.transparent,
                  ),
                  child: Icon(
                    _currentIndex == 3 ? Icons.person : Icons.person_outline,
                    size: 24,
                    color: _currentIndex == 3
                        ? AppTheme.textPrimary
                        : AppTheme.textTertiary,
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}