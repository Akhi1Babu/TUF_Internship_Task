import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';
import '../core/app_style.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    // Navigate to AuthWrapper after animation duration
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Force the background to match our native splash color #0B0B0F
    const Color splashBg = AppStyle.background;

    return Scaffold(
      backgroundColor: splashBg,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: splashBg, 
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: Lottie.asset(
                'assets/lottie/money_animation.json',
                fit: BoxFit.contain,
                frameRate: FrameRate.max,
                errorBuilder: (context, error, stackTrace) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppStyle.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppStyle.neonGlow,
                      ),
                      child: const Icon(Icons.wallet, color: Colors.black, size: 40),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            // Subtle premium loader
            const Text(
              'SECURE TRANSACTION ENGINE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 100,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  color: AppStyle.primary,
                  minHeight: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


