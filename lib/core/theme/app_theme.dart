import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Matching Website Design
  static const Color primary = Color(0xFF3B82F6); // Blue (59, 130, 246)
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryDark = Color(0xFF2563EB);
  
  static const Color secondary = Color(0xFF9333EA); // Purple (147, 51, 234)
  static const Color secondaryLight = Color(0xFFA855F7);
  static const Color secondaryDark = Color(0xFF7C3AED);
  
  static const Color accent = Color(0xFF22D3EE); // Cyan (34, 211, 238)
  static const Color accentLight = Color(0xFF67E8F9);
  static const Color accentDark = Color(0xFF06B6D4);
  
  static const Color background = Color(0xFF111827); // Dark gray (17, 24, 39)
  static const Color backgroundSecondary = Color(0xFF1F2937); // (31, 41, 55)
  static const Color surface = Color(0xFF374151); // (55, 65, 81)
  static const Color surfaceElevated = Color(0xFF4B5563); // (75, 85, 99)
  
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCBD5E1);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFF0F0F17);
  
  static const Color border = Color(0xFF334155);
  static const Color borderLight = Color(0xFF475569);
  
  // Semantic colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Safe font helper that falls back to system fonts
  static TextStyle _safeGoogleFont({
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
    Color? color,
  }) {
    try {
      return GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    } catch (e) {
      // Fallback to system font if Google Fonts fails
      return TextStyle(
        fontFamily: 'System',
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        surface: background,
        surfaceContainer: surface,
        surfaceContainerHighest: surfaceElevated,
        onPrimary: textInverse,
        onSecondary: textInverse,
        onTertiary: textInverse,
        onSurface: textPrimary,
        outline: border,
        error: error,
      ),
      
      // Typography with safe font loading and fallbacks
      textTheme: _buildSafeTextTheme(),
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 8,
        surfaceTintColor: primary.withValues(alpha: 0.1),
        titleTextStyle: _safeGoogleFont(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: surface.withValues(alpha: 0.7),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: border.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textInverse,
          elevation: 4,
          shadowColor: primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          textStyle: _safeGoogleFont(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.025,
          ),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        labelStyle: _safeGoogleFont(color: textMuted),
        hintStyle: _safeGoogleFont(color: textMuted),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: border.withValues(alpha: 0.2),
        space: 1,
        thickness: 1,
      ),
    );
  }

  // Custom gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [background, backgroundSecondary, surface],
  );

  // Box shadows
  static List<BoxShadow> get elevation1 => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.1),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get elevation2 => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.15),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevation3 => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primary.withValues(alpha: 0.2),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // Responsive breakpoints
  static const double mobileBreakpoint = 768.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1200.0;

  // Responsive utility methods
  static bool isMobile(double width) => width < mobileBreakpoint;
  static bool isTablet(double width) => width >= mobileBreakpoint && width < desktopBreakpoint;
  static bool isDesktop(double width) => width >= desktopBreakpoint;

  // Responsive padding
  static EdgeInsets getResponsivePadding(double screenWidth) {
    if (isMobile(screenWidth)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(screenWidth)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  // Responsive font size scaling
  static double getResponsiveFontSize(double screenWidth, double baseSize) {
    if (isMobile(screenWidth)) {
      return baseSize * 0.9;
    } else if (isTablet(screenWidth)) {
      return baseSize * 0.95;
    } else {
      return baseSize;
    }
  }

  // Grid columns based on screen size
  static int getGridColumns(double screenWidth) {
    if (isMobile(screenWidth)) {
      return 1;
    } else if (isTablet(screenWidth)) {
      return 2;
    } else {
      return 3;
    }
  }

  // Enhanced animations
  static Duration get shortAnimation => const Duration(milliseconds: 200);
  static Duration get mediumAnimation => const Duration(milliseconds: 400);
  static Duration get longAnimation => const Duration(milliseconds: 800);
  
  // Smooth curves
  static Curve get smoothCurve => Curves.easeOutCubic;
  static Curve get bouncyCurve => Curves.elasticOut;

  // Safe text theme that gracefully handles Google Fonts failures
  static TextTheme _buildSafeTextTheme() {
    try {
      return GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: _safeGoogleFont(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.02,
          height: 1.1,
        ),
        displayMedium: _safeGoogleFont(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.02,
          height: 1.1,
        ),
        displaySmall: _safeGoogleFont(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.01,
          height: 1.2,
        ),
        headlineLarge: _safeGoogleFont(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.01,
          height: 1.3,
        ),
        headlineMedium: _safeGoogleFont(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.01,
          height: 1.3,
        ),
        headlineSmall: _safeGoogleFont(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: _safeGoogleFont(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: _safeGoogleFont(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodySmall: _safeGoogleFont(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: _safeGoogleFont(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.05,
        ),
      );
    } catch (e) {
      // Return system font theme if Google Fonts completely fails
      return ThemeData.dark().textTheme;
    }
  }
}