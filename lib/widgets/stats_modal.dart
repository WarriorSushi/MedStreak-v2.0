import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../utils/theme.dart';
import '../services/game_service.dart';
import '../models/medical_models.dart';

class StatsModal extends ConsumerWidget {
  const StatsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameServiceProvider);
    final stats = gameState.stats;
    
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryNeon.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Title with Lottie animation
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo animation
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Lottie.asset(
                      'assets/lottie/logo.json',
                      repeat: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Stats',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBright,
                      shadows: [
                        Shadow(
                          color: AppTheme.primaryNeon.withOpacity(0.5),
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: AppTheme.dividerDark,
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
            // Current streak
            _buildStreakDisplay(stats.currentStreak),
            
            // Stats cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(20),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 1.2,
                children: [
                  _buildStatCard(
                    title: 'Best Streak',
                    value: stats.bestStreak.toString(),
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: 'Total Questions',
                    value: stats.totalQuestions.toString(),
                    icon: Icons.help_outline,
                    color: AppTheme.secondaryNeon,
                  ),
                  _buildStatCard(
                    title: 'Correct',
                    value: '${stats.correctAnswers}',
                    icon: Icons.check_circle_outline,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: 'Accuracy',
                    value: stats.totalQuestions > 0
                        ? '${(stats.correctAnswers / stats.totalQuestions * 100).toStringAsFixed(1)}%'
                        : '0%',
                    icon: Icons.percent,
                    color: AppTheme.primaryNeon,
                  ),
                ],
              ),
            ),
            
            // Accuracy by difficulty
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Accuracy by Difficulty',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textBright,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAccuracyBar(
                    label: 'Easy',
                    percent: stats.accuracyByDifficulty[ParameterDifficulty.easy] ?? 0.0,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 10),
                  _buildAccuracyBar(
                    label: 'Medium',
                    percent: stats.accuracyByDifficulty[ParameterDifficulty.medium] ?? 0.0,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 10),
                  _buildAccuracyBar(
                    label: 'Hard',
                    percent: stats.accuracyByDifficulty[ParameterDifficulty.hard] ?? 0.0,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 10),
                  _buildAccuracyBar(
                    label: 'Legendary',
                    percent: stats.accuracyByDifficulty[ParameterDifficulty.legendary] ?? 0.0,
                    color: AppTheme.primaryNeon,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Removed _calculateAccuracy method as it's no longer needed
  
  Widget _buildStreakDisplay(int streak) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          const Text(
            'CURRENT STREAK',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: AppTheme.primaryNeon,
                size: 30,
              ),
              const SizedBox(width: 10),
              Text(
                streak.toString(),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBright,
                  shadows: [
                    Shadow(
                      color: AppTheme.primaryNeon.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBright,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 5,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccuracyBar({
    required String label,
    required double percent,
    required Color color,
  }) {
    // No need for context override as we'll use a LayoutBuilder instead
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Background
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Progress
                Container(
                  height: 8,
                  width: constraints.maxWidth * percent,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
