import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_style.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFEEF1F7), // Warm blue-gray, not blinding white
    primaryColor: AppStyle.primary,
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      headlineLarge: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF1A1D2E)),
      titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: const Color(0xFF1A1D2E)),
      bodyLarge: GoogleFonts.inter(color: const Color(0xFF3A3D4E)),
    ),
    colorScheme: ColorScheme.light(
      primary: AppStyle.primary,
      secondary: AppStyle.secondary,
      surface: const Color(0xFFFFFFFF), // Cards are crisp white
      onSurface: const Color(0xFF1A1D2E), // Deep charcoal text
      error: Colors.redAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFEEF1F7),
      elevation: 0,
      foregroundColor: Color(0xFF1A1D2E),
      iconTheme: IconThemeData(color: Color(0xFF1A1D2E)),
      centerTitle: true,
    ),
    dividerColor: const Color(0xFFD5D8E5),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ClassicPageTransitionsBuilder(),
        TargetPlatform.iOS: ClassicPageTransitionsBuilder(),
      },
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: const Color(0xFF1A1D2E).withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppStyle.background,
    primaryColor: AppStyle.primary,
    cardColor: AppStyle.surface,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      headlineLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.inter(color: Colors.white70),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppStyle.primary,
      secondary: AppStyle.secondary,
      onPrimary: Colors.white,
      surface: AppStyle.surface,
      error: Colors.redAccent,
      tertiary: AppStyle.accentGreen,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      centerTitle: true,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ClassicPageTransitionsBuilder(),
        TargetPlatform.iOS: ClassicPageTransitionsBuilder(),
      },
    ),
    useMaterial3: true,
  );
}

class ClassicPageTransitionsBuilder extends PageTransitionsBuilder {
  const ClassicPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const double beginScale = 0.95;
    const Curve curve = Curves.fastOutSlowIn;

    // Slide up animation
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: curve));

    // Fade animation
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: const Interval(0.0, 0.6, curve: curve)));

    // Scale animation
    final scaleAnimation = Tween<double>(
      begin: beginScale,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: curve));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: child,
        ),
      ),
    );
  }
}

