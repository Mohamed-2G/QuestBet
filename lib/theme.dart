import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class AppTheme {
  // QuestBet Yellow Color Palette - Energetic & Vibrant
  static const Color primaryYellow = Color(0xFFFFD700); // Bright golden yellow
  static const Color yellowLight = Color(0xFFFFEB3B); // Lighter yellow
  static const Color yellowDark = Color(0xFFFFC107); // Darker yellow
  static const Color yellowAccent = Color(0xFFFFF59D); // Pale yellow/cream
  
  // Background Colors
  static const Color background = Color(0xFFFFF9E6); // Very light yellow/cream
  static const Color backgroundSecondary = Color(0xFFFFF3CD); // Slightly darker cream
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceElevated = Color(0xFFFFFEF7); // Subtle elevated white
  
  // Accent Colors
  static const Color success = Color(0xFF4CAF50); // Fresh green
  static const Color danger = Color(0xFFF44336); // Energetic red
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color info = Color(0xFF2196F3); // Blue
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A); // Almost black
  static const Color textSecondary = Color(0xFF666666); // Medium gray
  static const Color textTertiary = Color(0xFF999999); // Light gray
  static const Color textOnYellow = Color(0xFF1A1A1A); // Dark text on yellow

  // QuestBet Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFFEB3B)],
  );

  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFC107), Color(0xFFFFB300)], // Slightly darker for better contrast
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF9E6), Color(0xFFFFF3CD)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFFEF7)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
  );

  // Quest-themed Quotes
  static final List<String> questQuotes = [
    "Every quest begins with a single step!",
    "Level up your life, one task at a time!",
    "You're on a quest for greatness!",
    "Complete your quests, earn your rewards!",
    "Adventure awaits in every completed task!",
    "Your journey to success starts now!",
    "Quest complete! Keep going!",
    "Turn your goals into quests!",
    "Every task is a quest worth completing!",
    "Unlock achievements, complete quests!",
  ];

  static String getRandomQuote() {
    final random = Random();
    return questQuotes[random.nextInt(questQuotes.length)];
  }

  // Dynamic Shadows
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: primaryYellow.withOpacity(0.1),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryYellow.withOpacity(0.15),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primaryYellow.withOpacity(0.2),
      blurRadius: 30,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get yellowGlow => [
    BoxShadow(
      color: primaryYellow.withOpacity(0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get successGlow => [
    BoxShadow(
      color: success.withOpacity(0.3),
      blurRadius: 15,
      spreadRadius: 2,
    ),
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      colorScheme: const ColorScheme.light(
        primary: primaryYellow,
        secondary: yellowLight,
        error: danger,
        surface: surface,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onError: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme.apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
      ).copyWith(
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryYellow.withOpacity(0.3), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryYellow.withOpacity(0.2), width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryYellow, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: GoogleFonts.poppins(
          color: textTertiary,
          fontSize: 14,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryYellow,
        unselectedItemColor: textTertiary,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Quest-themed container with yellow accent
  static Widget questContainer({
    required Widget child,
    Color? color,
    double borderRadius = 20,
    List<BoxShadow>? boxShadow,
    EdgeInsets? padding,
    bool withYellowBorder = false,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? surface,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? cardShadow,
        border: withYellowBorder
            ? Border.all(color: primaryYellow, width: 2)
            : null,
      ),
      child: child,
    );
  }

  // Yellow gradient container
  static Widget yellowGradientContainer({
    required Widget child,
    double borderRadius = 20,
    List<BoxShadow>? boxShadow,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: yellowGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow ?? yellowGlow,
      ),
      child: child,
    );
  }

  // Text with yellow outline effect (like the icon)
  static Widget outlinedText({
    required String text,
    required double fontSize,
    FontWeight fontWeight = FontWeight.w700,
    Color textColor = Colors.white,
    Color outlineColor = primaryYellow,
    double outlineWidth = 3,
  }) {
    return Stack(
      children: [
        // Outline
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = outlineWidth
              ..color = outlineColor,
          ),
        ),
        // Fill
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ],
    );
  }

  // Coin/Currency display widget
  static Widget coinDisplay({
    required int amount,
    double size = 24,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: yellowGradient,
            shape: BoxShape.circle,
            boxShadow: yellowGlow,
          ),
          child: Center(
            child: Text(
              '\$',
              style: GoogleFonts.poppins(
                fontSize: size * 0.6,
                fontWeight: FontWeight.w800,
                color: textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$amount',
          style: GoogleFonts.poppins(
            fontSize: size * 0.8,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ],
    );
  }
}
