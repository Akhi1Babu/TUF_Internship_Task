import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/app_style.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final List<Color>? glowColors;

  const GlassCard({
    super.key, 
    required this.child, 
    this.width, 
    this.height, 
    this.glowColors
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Glow
        Positioned(
          right: -20,
          top: -20,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (glowColors?.first ?? AppStyle.primary).withValues(alpha: 0.4),
                  blurRadius: 80,
                  spreadRadius: 20,
                )
              ],
            ),
          ),
        ),
        Positioned(
          left: 50,
          bottom: -30,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (glowColors?.last ?? AppStyle.secondary).withValues(alpha: 0.3),
                  blurRadius: 80,
                  spreadRadius: 20,
                )
              ],
            ),
          ),
        ),
        
        // Blurred Glass Layer
        ClipRRect(
          borderRadius: AppStyle.rXL,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: width,
              height: height,
              padding: EdgeInsets.all(AppStyle.pL),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: AppStyle.rXL,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.5,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
