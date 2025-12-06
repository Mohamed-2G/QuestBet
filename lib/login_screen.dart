import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'game_state.dart';
import 'theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Toggle between Login and Register
  bool isRegistering = false; 

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // QuestBet Logo/Title
                    AppTheme.outlinedText(
                      text: "QUESTBET",
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      textColor: Colors.white,
                      outlineColor: AppTheme.primaryYellow,
                      outlineWidth: 4,
                    ),
                    const SizedBox(height: 16),
                    // Tagline
                    Text(
                      "Turn your goals into quests. Earn rewards.",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Username field (only for registration)
                    if (isRegistering)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildTextField(
                          _usernameController, 
                          "Username", 
                          Icons.person_outline,
                        ),
                      ),

                    // Email/Username field
                    _buildTextField(
                      _emailController, 
                      isRegistering ? "Email Address" : "Username or Email", 
                      isRegistering ? Icons.email_outlined : Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    _buildTextField(
                      _passwordController, 
                      "Password", 
                      Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),

                    // LOG IN / CREATE ACCOUNT button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppTheme.yellowGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.yellowGlow,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final gameState = context.read<GameState>();
                            String? error;

                            if (isRegistering) {
                              error = await gameState.register(
                                username: _usernameController.text.trim(),
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                            } else {
                              error = await gameState.login(
                                loginInput: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                            }

                            if (mounted) {
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("❌ $error"),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.celebration, color: Colors.white, size: 24),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            isRegistering 
                                                ? "🎉 Quest Started! Your adventure begins!" 
                                                : "✨ Welcome back, Quest Master!",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppTheme.success,
                                    duration: const Duration(seconds: 3),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                _emailController.clear();
                                _passwordController.clear();
                                _usernameController.clear();
                              }
                            }
                          }
                        },
                        child: context.watch<GameState>().isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppTheme.background,
                                  strokeWidth: 2,
                                ),
                              )
                            : AppTheme.outlinedText(
                                text: isRegistering ? "START QUEST" : "LOG IN",
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                textColor: Colors.white,
                                outlineColor: AppTheme.textPrimary,
                                outlineWidth: 2,
                              ),
                      ),
                    ),

                    // CREATE ACCOUNT / LOG IN toggle button
                    if (!isRegistering) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppTheme.primaryYellow,
                              width: 2.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              isRegistering = true;
                              _formKey.currentState?.reset();
                            });
                          },
                          child: Text(
                            "CREATE ACCOUNT",
                            style: GoogleFonts.poppins(
                              color: AppTheme.primaryYellow,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Toggle back to login
                    if (isRegistering) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isRegistering = false;
                            _formKey.currentState?.reset();
                          });
                        },
                        child: Text(
                          "Already have an account? Log In",
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    // Forgot Password link (only on login)
                    if (!isRegistering) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Forgot password feature coming soon!"),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String hint, 
    IconData icon, 
    {bool isPassword = false}
  ) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.poppins(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return "Required";
        if (isPassword && value.length < 6) return "Password too short (min 6)";
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.primaryYellow),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.primaryYellow.withOpacity(0.3),
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.primaryYellow.withOpacity(0.3),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.primaryYellow,
            width: 2.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}
