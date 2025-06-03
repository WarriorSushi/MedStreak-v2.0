import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../services/game_service.dart';
import '../utils/theme.dart';

class MainMenuScreen extends ConsumerStatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends ConsumerState<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }
  
  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final highestStreak = userProfile.highestStreak;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Logo and title
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.neonShadow(AppTheme.primaryNeon),
                      ),
                      child: Lottie.asset(
                        'assets/lottie/logo.json',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
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
              
              const Spacer(),
              
              // Best streak display
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryNeon.withOpacity(0.2),
                          AppTheme.secondaryNeon.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryNeon,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryNeon.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: AppTheme.primaryNeon,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'BEST STREAK',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$highestStreak',
                              style: const TextStyle(
                                color: AppTheme.textBright,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Menu buttons
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildMenuButton(
                        'PLAY GAME',
                        Icons.play_arrow_rounded,
                        AppTheme.primaryNeon,
                        () {
                          // Reset practice mode to false and navigate to game screen
                          ref.read(userProfileProvider.notifier).updateSettings(
                            userProfile.settings.copyWith(practiceMode: false)
                          );
                          context.go('/game');
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        'PRACTICE MODE',
                        Icons.school,
                        Colors.green,
                        () {
                          // Set practice mode to true and navigate to game screen
                          ref.read(userProfileProvider.notifier).updateSettings(
                            userProfile.settings.copyWith(practiceMode: true)
                          );
                          context.go('/practice');
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        'SETTINGS',
                        Icons.settings,
                        AppTheme.secondaryNeon,
                        () {
                          context.go('/settings');
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMenuButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.2),
              AppTheme.surfaceDark.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
