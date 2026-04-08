import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppStyle {
  // ── Core Palette ──────────────────────────────────────────────────────────
  static const Color background  = Color(0xFF0B0B0F);
  static const Color surface     = Color(0xFF16161E);
  static const Color primary     = Color(0xFFC1FF72);
  static const Color secondary   = Color(0xFF8E54E9);
  static const Color accentRed   = Color(0xFFFF4B6E);
  static const Color accentGreen = Color(0xFF00D2A0);

  // ── Theme-Aware Color Helpers ─────────────────────────────────────────────
  static Color getBg(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;
  static Color getSurface(BuildContext context) => Theme.of(context).colorScheme.surface;
  static Color getOnSurface(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : const Color(0xFF1A1D2E);
  static Color getSubtitle(BuildContext context) => Theme.of(context).brightness == Brightness.dark
      ? Colors.white38
      : const Color(0xFF6B7080);

  // ── Responsive Spacing (Scalable) ────────────────────────────────────────────
  static double get pXL => 40.0.w;
  static double get pL  => 24.0.w;
  static double get pM  => 16.0.w;
  static double get pS  => 8.0.w;

  // ── Responsive Font Sizes (Scalable) ──────────────────────────────────────────
  static double get fXXL => 44.0.sp;
  static double get fXL  => 32.0.sp;
  static double get fL   => 24.0.sp;
  static double get fM   => 16.0.sp;
  static double get fS   => 13.0.sp;
  static double get fXS  => 10.0.sp;
  static double get fXXS => 8.0.sp;

  // ── Responsive Corner Radii (Scalable) ────────────────────────────────────────
  static BorderRadius get rXL => BorderRadius.circular(40.0.r);
  static BorderRadius get rL  => BorderRadius.circular(24.0.r);
  static BorderRadius get rM  => BorderRadius.circular(16.0.r);
  static BorderRadius get rS  => BorderRadius.circular(8.0.r);

  // ── Card Gradients ────────────────────────────────────────────────────────
  static const List<Color> mainCardGradient = [Color(0xFF8E54E9), Color(0xFF4B2CAB)];
  static const Color glassWhite = Color(0x0DFFFFFF);

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get stealthShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 30.0.r,
      offset: Offset(0, 15.0.h),
    )
  ];

  static List<BoxShadow> get neonGlow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.3),
      blurRadius: 20.0.r,
      spreadRadius: 2.0.r,
    )
  ];
}
