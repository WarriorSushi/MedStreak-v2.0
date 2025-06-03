import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.forward();
    
    // Navigate to the game screen after animation completes
    Timer(const Duration(seconds: 3), () {
      context.go('/game');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animation using Lottie
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: AppTheme.neonShadow(AppTheme.primaryNeon),
              ),
              child: Lottie.asset(
                'assets/lottie/logo.json',
                controller: _controller,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 30),
            // App title with neon effect
            Text(
              'MedStreak',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppTheme.textBright,
                shadows: [
                  Shadow(
                    color: AppTheme.primaryNeon.withOpacity(0.8),
                    blurRadius: 10,
                    offset: const Offset(0, 0),
                  ),
                  Shadow(
                    color: AppTheme.secondaryNeon.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Tagline
            Text(
              'Master Medical Parameters',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
