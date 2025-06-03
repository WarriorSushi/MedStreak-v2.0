import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/theme.dart';
import '../widgets/card_container.dart';
import '../services/game_service.dart' as game_service;
import '../notifiers/user_profile_notifier.dart';
import '../models/user_profile.dart' as user_model;

// Define additional color constants used throughout the app
extension AppThemeExtension on AppTheme {
  static Color get tertiaryNeon => Colors.teal;
  static Color get quaternaryNeon => Colors.amber;
}

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We'll use gameState when implementing game functionality
    // final gameState = ref.watch(game_service.gameServiceProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Main game area with card container
            const CardContainer(),
            
            // Settings button
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.neonShadow(AppTheme.secondaryNeon),
                ),
                child: FloatingActionButton(
                  backgroundColor: AppTheme.surfaceDark,
                  foregroundColor: AppTheme.secondaryNeon,
                  onPressed: () {
                    _showSettingsModal(context, ref);
                  },
                  child: const Icon(Icons.settings),
                ),
              ),
            ),
            
            // Stats button
            Positioned(
              bottom: 20,
              left: 20,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.neonShadow(AppTheme.primaryNeon),
                ),
                child: FloatingActionButton(
                  backgroundColor: AppTheme.surfaceDark,
                  foregroundColor: AppTheme.primaryNeon,
                  onPressed: () {
                    _showStatsModal(context, ref);
                  },
                  child: const Icon(Icons.bar_chart),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSettingsModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SettingsModal(ref: ref),
    );
  }
  
  void _showStatsModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _StatsModal(ref: ref),
    );
  }
}

class _SettingsModal extends ConsumerWidget {
  final WidgetRef ref;
  
  const _SettingsModal({required this.ref});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userProfileProvider).settings;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: AppTheme.neonShadow(AppTheme.secondaryNeon),
        border: Border(
          top: BorderSide(color: AppTheme.secondaryNeon, width: 2),
          left: BorderSide(color: AppTheme.secondaryNeon.withOpacity(0.5), width: 2),
          right: BorderSide(color: AppTheme.secondaryNeon.withOpacity(0.5), width: 2),
        ),
      ),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Game Settings',
                  style: TextStyle(
                    color: AppTheme.secondaryNeon,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: AppTheme.neonShadow(AppTheme.secondaryNeon),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Unit System Switch
              _buildSwitchRow(
                "Unit System",
                "${settings.unitSystem.name.toUpperCase()} Units",
                AppTheme.accentNeon,
                () {
                  final newSystem = settings.unitSystem == user_model.UnitSystem.si 
                      ? user_model.UnitSystem.conventional 
                      : user_model.UnitSystem.si;
                  ref.read(userProfileProvider.notifier).updateSettings(
                    settings.copyWith(unitSystem: newSystem),
                  );
                },
              ),
              
              // Sex Context Switch
              _buildSwitchRow(
                "Sex Context",
                settings.sexContext.name.toUpperCase(),
                AppTheme.secondaryNeon,
                () {
                  final newContext = settings.sexContext == user_model.SexContext.male
                      ? user_model.SexContext.female
                      : settings.sexContext == user_model.SexContext.female
                          ? user_model.SexContext.general
                          : user_model.SexContext.male;
                  ref.read(userProfileProvider.notifier).updateSettings(
                    settings.copyWith(sexContext: newContext),
                  );
                },
              ),
              
              // Difficulty Level Switch
              _buildSwitchRow(
                "Difficulty",
                settings.difficulty.name.toUpperCase(),
                AppTheme.primaryNeon,
                () {
                  final newDifficulty = settings.difficulty == user_model.Difficulty.easy
                      ? user_model.Difficulty.medium
                      : settings.difficulty == user_model.Difficulty.medium
                          ? user_model.Difficulty.hard
                          : user_model.Difficulty.easy;
                  ref.read(userProfileProvider.notifier).updateSettings(
                    settings.copyWith(difficulty: newDifficulty),
                  );
                },
              ),
              
              // Sound Effects Toggle
              _buildToggleRow(
                "Sound Effects",
                settings.soundEnabled,
                AppThemeExtension.tertiaryNeon,
                (value) {
                  ref.read(userProfileProvider.notifier).updateSettings(
                    settings.copyWith(soundEnabled: value),
                  );
                },
              ),
              
              // Auto Mode Toggle
              _buildToggleRow(
                "Auto Unit Mode",
                settings.autoMode,
                AppThemeExtension.quaternaryNeon,
                (value) {
                  ref.read(userProfileProvider.notifier).updateSettings(
                    settings.copyWith(autoMode: value),
                  );
                },
              ),
              
              const SizedBox(height: 20),
              
              // Done Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceDark,
                    foregroundColor: AppTheme.secondaryNeon,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: AppTheme.secondaryNeon),
                    elevation: 5,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: AppTheme.secondaryNeon,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        BoxShadow(
                          color: AppTheme.secondaryNeon.withOpacity(0.8),
                          blurStyle: BlurStyle.outer,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String title, 
    String value, 
    Color color, 
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.8),
                    blurStyle: BlurStyle.outer,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  shadows: [
                    BoxShadow(
                      color: color.withOpacity(0.8),
                      blurStyle: BlurStyle.outer,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String title, 
    bool isEnabled, 
    Color color, 
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3),
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}

class _StatsModal extends ConsumerWidget {
  final WidgetRef ref;
  
  const _StatsModal({required this.ref});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStats = ref.watch(game_service.gameServiceProvider).stats;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryNeon.withOpacity(0.8),
            blurStyle: BlurStyle.outer,
            offset: const Offset(0, 0),
          ),
        ],
        border: Border(
          top: BorderSide(color: AppTheme.primaryNeon, width: 2),
          left: BorderSide(color: AppTheme.primaryNeon.withOpacity(0.5), width: 2),
          right: BorderSide(color: AppTheme.primaryNeon.withOpacity(0.5), width: 2),
        ),
      ),
      child: Wrap(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Game Statistics',
                  style: TextStyle(
                    color: AppTheme.primaryNeon,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(
                        color: AppTheme.primaryNeon.withOpacity(0.8),
                        blurStyle: BlurStyle.outer,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Stats grid
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    'Current Streak',
                    '${gameStats.currentStreak}',
                    AppTheme.secondaryNeon,
                  ),
                  _buildStatCard(
                    'Correct',
                    '${gameStats.correctAnswers}',
                    AppTheme.primaryNeon,
                  ),
                  _buildStatCard(
                    'Incorrect',
                    '${gameStats.totalQuestions - gameStats.correctAnswers}',
                    AppThemeExtension.tertiaryNeon,
                  ),
                  _buildStatCard(
                    'Best Streak',
                    '${gameStats.bestStreak}',
                    AppThemeExtension.quaternaryNeon,
                  ),
                  _buildStatCard(
                    'Accuracy',
                    '${gameStats.totalQuestions > 0 ? (gameStats.correctAnswers / gameStats.totalQuestions * 100).toStringAsFixed(1) : 0}%',
                    AppThemeExtension.tertiaryNeon,
                  ),
                  _buildStatCard(
                    'Total Played',
                    '${gameStats.totalQuestions}',
                    AppThemeExtension.quaternaryNeon,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Done Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceDark,
                    foregroundColor: AppTheme.primaryNeon,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: AppTheme.primaryNeon),
                    elevation: 5,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: AppTheme.primaryNeon,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        BoxShadow(
                          color: AppTheme.primaryNeon.withOpacity(0.8),
                          blurStyle: BlurStyle.outer,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.8),
            blurStyle: BlurStyle.outer,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                BoxShadow(
                  color: color.withOpacity(0.8),
                  blurStyle: BlurStyle.outer,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
