import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Neon Colors - Enhanced palette
  static const Color primaryNeon = Color(0xFFFF10F0); // Neon pink/magenta
  static const Color secondaryNeon = Color(0xFF10FFFF); // Neon cyan
  static const Color accentNeon = Color(0xFF10FF10); // Neon green
  static const Color warningNeon = Color(0xFFFFFF10); // Neon yellow
  static const Color errorNeon = Color(0xFFFF1010); // Neon red
  
  // Dark Background Variations
  static const Color backgroundDark = Color(0xFF0A0A0A); // Deepest dark
  static const Color surfaceDark = Color(0xFF1A1A1A); // Card surfaces
  static const Color containerDark = Color(0xFF2A2A2A); // Containers
  static const Color cardDark = Color(0xFF202020); // Card background
  static const Color dividerDark = Color(0xFF333333); // Divider color
  
  // Text Colors
  static const Color textBright = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFFCCCCCC); // Light gray
  static const Color textTertiary = Color(0xFF888888); // Medium gray
  static const Color textMuted = Color(0xFF555555); // Dark gray

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryNeon,
      secondaryNeon,
    ],
    stops: [0.0, 1.0],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundDark,
      surfaceDark,
    ],
    stops: [0.0, 1.0],
  );

  static const RadialGradient cardGradient = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.5,
    colors: [
      surfaceDark,
      backgroundDark,
    ],
    stops: [0.0, 1.0],
  );

  static LinearGradient neonGlowGradient(Color neonColor) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        neonColor.withOpacity(0.3),
        neonColor.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  // Box Shadow Definitions
  static List<BoxShadow> neonShadow(Color neonColor, {double intensity = 1.0}) {
    return [
      BoxShadow(
        color: neonColor.withOpacity(0.5 * intensity),
        blurRadius: 20 * intensity,
        spreadRadius: 5 * intensity,
      ),
      BoxShadow(
        color: neonColor.withOpacity(0.3 * intensity),
        blurRadius: 40 * intensity,
        spreadRadius: 10 * intensity,
      ),
    ];
  }

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primaryNeon.withOpacity(0.2),
      blurRadius: 30,
      spreadRadius: 5,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: secondaryNeon.withOpacity(0.1),
      blurRadius: 50,
      spreadRadius: 8,
      offset: const Offset(0, 15),
    ),
  ];

  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: primaryNeon.withOpacity(0.4),
      blurRadius: 15,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.8),
      blurRadius: 10,
      spreadRadius: 1,
      offset: const Offset(0, 5),
    ),
  ];

  // Border Definitions
  static Border neonBorder(Color neonColor, {double width = 2.0}) {
    return Border.all(
      color: neonColor,
      width: width,
    );
  }

  // Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryNeon,
      scaffoldBackgroundColor: backgroundDark,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: secondaryNeon,
        surface: surfaceDark,
        background: backgroundDark,
        error: errorNeon,
        onPrimary: backgroundDark,
        onSecondary: backgroundDark,
        onSurface: textBright,
        onBackground: textBright,
        onError: backgroundDark,
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          // Display styles (largest)
          displayLarge: TextStyle(
            color: textBright,
            fontSize: 57,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.25,
          ),
          displayMedium: TextStyle(
            color: textBright,
            fontSize: 45,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: textBright,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
          
          // Headline styles
          headlineLarge: TextStyle(
            color: textBright,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: textBright,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          headlineSmall: TextStyle(
            color: textBright,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
          
          // Title styles
          titleLarge: TextStyle(
            color: textBright,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: textBright,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: TextStyle(
            color: textBright,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          
          // Body styles
          bodyLarge: TextStyle(
            color: textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          bodyMedium: TextStyle(
            color: textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
          bodySmall: TextStyle(
            color: textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          
          // Label styles
          labelLarge: TextStyle(
            color: textBright,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: TextStyle(
            color: textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          labelSmall: TextStyle(
            color: textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNeon,
          foregroundColor: backgroundDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNeon,
          side: const BorderSide(color: primaryNeon, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryNeon,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textBright),
        titleTextStyle: TextStyle(
          color: textBright,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: primaryNeon, width: 1),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryNeon),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryNeon.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryNeon, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textTertiary),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textBright,
        size: 24,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: textTertiary.withOpacity(0.3),
        thickness: 1,
      ),
    );
  }
}

// Custom Decoration Classes
class NeonDecorations {
  static BoxDecoration cardDecoration({
    Color? borderColor,
    double borderWidth = 2.0,
    double borderRadius = 20.0,
    List<BoxShadow>? customShadows,
  }) {
    return BoxDecoration(
      gradient: AppTheme.cardGradient,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppTheme.primaryNeon,
        width: borderWidth,
      ),
      boxShadow: customShadows ?? AppTheme.cardShadow,
    );
  }

  static BoxDecoration buttonDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 16.0,
    bool isPressed = false,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppTheme.primaryNeon,
      borderRadius: BorderRadius.circular(borderRadius),
      border: borderColor != null 
          ? Border.all(color: borderColor, width: 2)
          : null,
      boxShadow: isPressed 
          ? AppTheme.neonShadow(AppTheme.primaryNeon, intensity: 0.5)
          : AppTheme.buttonShadow,
    );
  }

  static BoxDecoration containerDecoration({
    Color? backgroundColor,
    Color? borderColor,
    double borderRadius = 12.0,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppTheme.surfaceDark.withOpacity(0.8),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? AppTheme.primaryNeon.withOpacity(0.5),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: (borderColor ?? AppTheme.primaryNeon).withOpacity(0.2),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration streakCounterDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppTheme.primaryNeon.withOpacity(0.3),
          AppTheme.secondaryNeon.withOpacity(0.3),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(25),
      border: Border.all(
        color: AppTheme.primaryNeon,
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryNeon.withOpacity(0.4),
          blurRadius: 15,
          spreadRadius: 3,
        ),
        BoxShadow(
          color: AppTheme.secondaryNeon.withOpacity(0.2),
          blurRadius: 25,
          spreadRadius: 5,
        ),
      ],
    );
  }

  static BoxDecoration difficultyBadgeDecoration(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: color,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    );
  }

  static BoxDecoration errorOverlayDecoration(double animationValue) {
    return BoxDecoration(
      color: AppTheme.errorNeon.withOpacity(animationValue * 0.9),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      boxShadow: [
        BoxShadow(
          color: AppTheme.errorNeon.withOpacity(animationValue * 0.5),
          blurRadius: 15,
          spreadRadius: 3,
        ),
      ],
    );
  }
}

// Animation Curves
class AppCurves {
  static const Curve elasticOut = Curves.elasticOut;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve cardEntry = Curves.elasticOut;
  static const Curve cardExit = Curves.easeInBack;
  static const Curve errorBounce = Curves.elasticOut;
  static const Curve buttonPress = Curves.easeOut;
  static const Curve glow = Curves.easeInOut;
}

// Animation Durations
class AppDurations {
  static const Duration cardEntry = Duration(milliseconds: 800);
  static const Duration cardExit = Duration(milliseconds: 300);
  static const Duration errorAnimation = Duration(milliseconds: 600);
  static const Duration buttonPress = Duration(milliseconds: 200);
  static const Duration glowCycle = Duration(milliseconds: 2000);
  static const Duration unitToggle = Duration(milliseconds: 400);
}

// Text Styles with Neon Effects
class NeonTextStyles {
  static TextStyle neonText({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppTheme.primaryNeon,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      shadows: [
        Shadow(
          color: color.withOpacity(0.8),
          blurRadius: 10,
        ),
        Shadow(
          color: color.withOpacity(0.4),
          blurRadius: 20,
        ),
      ],
    );
  }

  static TextStyle cardTitle() {
    return NeonTextStyles.neonText(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppTheme.textBright,
    );
  }

  static TextStyle cardValue() {
    return NeonTextStyles.neonText(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: AppTheme.textBright,
    );
  }

  static TextStyle streakCounter() {
    return NeonTextStyles.neonText(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: AppTheme.textBright,
    );
  }

  static TextStyle difficultyBadge() {
    return const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    );
  }

  static TextStyle errorMessage() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.black,
          blurRadius: 5,
        ),
      ],
    );
  }
}
