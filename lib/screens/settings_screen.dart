import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/medical_models.dart';
import '../services/game_service.dart';
import '../services/sound_service.dart';
import '../utils/theme.dart';
import '../data/parameter_categories.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final settings = userProfile.settings;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppTheme.textBright,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textBright),
          onPressed: () => context.go('/menu'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Unit System Section
              _buildSectionTitle('Unit System'),
              const SizedBox(height: 10),
              _buildUnitSystemSelector(settings, ref),
              
              const SizedBox(height: 24),
              
              // Sex Context Section
              _buildSectionTitle('Sex Context Preference'),
              const SizedBox(height: 10),
              _buildSexContextSelector(settings, ref),
              
              const SizedBox(height: 24),
              
              // Difficulty Section
              _buildSectionTitle('Difficulty Level'),
              const SizedBox(height: 10),
              _buildDifficultySelector(settings, ref),
              
              const SizedBox(height: 24),
              
              // Sound & Feedback Settings
              _buildSectionTitle('Sound & Feedback'),
              const SizedBox(height: 10),
              _buildSwitchSetting(
                'Sound Effects',
                ref.watch(soundServiceProvider).settings.soundEnabled,
                (value) {
                  final soundService = ref.read(soundServiceProvider);
                  soundService.updateSettings(
                    soundService.settings.copyWith(soundEnabled: value)
                  );
                  
                  // Also play a sound if enabling sounds
                  if (value) {
                    soundService.playSound(SoundEffect.buttonTap);
                  }
                },
                AppTheme.primaryNeon,
              ),
              
              const SizedBox(height: 12),
              _buildSwitchSetting(
                'Haptic Feedback',
                ref.watch(soundServiceProvider).settings.hapticsEnabled,
                (value) {
                  final soundService = ref.read(soundServiceProvider);
                  soundService.updateSettings(
                    soundService.settings.copyWith(hapticsEnabled: value)
                  );
                  
                  // Provide haptic feedback when enabling
                  if (value) {
                    soundService.playHaptic(HapticFeedbackType.light);
                  }
                },
                Colors.purple,
              ),
              
              const SizedBox(height: 12),
              
              // Volume slider
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.volume_down,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                    Expanded(
                      child: Slider(
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        value: ref.watch(soundServiceProvider).settings.volume,
                        activeColor: AppTheme.primaryNeon,
                        inactiveColor: AppTheme.primaryNeon.withOpacity(0.2),
                        onChanged: ref.watch(soundServiceProvider).settings.soundEnabled
                            ? (value) {
                                final soundService = ref.read(soundServiceProvider);
                                soundService.setVolume(value);
                              }
                            : null,
                      ),
                    ),
                    const Icon(
                      Icons.volume_up,
                      color: AppTheme.textSecondary,
                      size: 22,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Test sounds button
              GestureDetector(
                onTap: () {
                  context.go('/sound-test');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNeon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryNeon.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.music_note,
                        color: AppTheme.primaryNeon,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Test Sound Effects',
                        style: TextStyle(
                          color: AppTheme.primaryNeon,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppTheme.primaryNeon,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Auto Mode Settings
              _buildSectionTitle('Unit Selection Mode'),
              const SizedBox(height: 10),
              _buildSwitchSetting(
                'Auto Unit Mode',
                settings.autoMode,
                (value) {
                  ref.read(userProfileProvider.notifier).updateSettings(
                    settings.copyWith(autoMode: value)
                  );
                },
                AppTheme.secondaryNeon,
              ),
              
              const SizedBox(height: 6),
              Text(
                'When enabled, both SI and conventional units will appear randomly for more varied practice.',
                style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Category Selection (for Practice Mode)
              _buildSectionTitle('Practice Categories'),
              const SizedBox(height: 10),
              _buildCategorySelector(settings, ref),
              
              const SizedBox(height: 24),
              
              // Reset data option
              _buildSectionTitle('Data Management'),
              const SizedBox(height: 10),
              _buildDataResetButton(context, ref),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 2, bottom: 5),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.primaryNeon, width: 1),
        ),
      ),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.primaryNeon,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildUnitSystemSelector(GameSettings settings, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _buildSelectionButton(
            'SI',
            settings.unitSystem == UnitSystem.si,
            () {
              ref.read(userProfileProvider.notifier).updateSettings(
                settings.copyWith(unitSystem: UnitSystem.si)
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSelectionButton(
            'Conventional',
            settings.unitSystem == UnitSystem.conventional,
            () {
              ref.read(userProfileProvider.notifier).updateSettings(
                settings.copyWith(unitSystem: UnitSystem.conventional)
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSexContextSelector(GameSettings settings, WidgetRef ref) {
    return Row(
      children: [
        for (final context in SexContext.values)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: context != SexContext.female ? 10 : 0,
              ),
              child: _buildSelectionButton(
                _getSexContextLabel(context),
                settings.preferredSexContext == context,
                () {
                  ref.read(userProfileProvider.notifier).updateSettings(
                    settings.copyWith(preferredSexContext: context)
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  String _getSexContextLabel(SexContext context) {
    switch (context) {
      case SexContext.male:
        return 'Male';
      case SexContext.female:
        return 'Female';
      case SexContext.general:
        return 'General';
    }
  }

  Widget _buildDifficultySelector(GameSettings settings, WidgetRef ref) {
    return Column(
      children: [
        for (final difficulty in ParameterDifficulty.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildSelectionButton(
              _getDifficultyLabel(difficulty),
              settings.difficulty == difficulty,
              () {
                ref.read(userProfileProvider.notifier).updateSettings(
                  settings.copyWith(difficulty: difficulty)
                );
              },
              color: _getDifficultyColor(difficulty),
            ),
          ),
      ],
    );
  }

  String _getDifficultyLabel(ParameterDifficulty difficulty) {
    switch (difficulty) {
      case ParameterDifficulty.easy:
        return 'Easy';
      case ParameterDifficulty.medium:
        return 'Medium';
      case ParameterDifficulty.hard:
        return 'Hard';
      case ParameterDifficulty.legendary:
        return 'Legendary';
    }
  }

  Color _getDifficultyColor(ParameterDifficulty difficulty) {
    switch (difficulty) {
      case ParameterDifficulty.easy:
        return Colors.green;
      case ParameterDifficulty.medium:
        return Colors.orange;
      case ParameterDifficulty.hard:
        return Colors.red;
      case ParameterDifficulty.legendary:
        return Colors.purple;
    }
  }

  Widget _buildSwitchSetting(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    Color activeColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activeColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textBright,
              fontSize: 16,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
            activeTrackColor: activeColor.withOpacity(0.3),
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.textSecondary.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(GameSettings settings, WidgetRef ref) {
    final categories = ParameterCategories.getAllCategories();
    return Column(
      children: [
        for (final category in categories)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildCategoryCheckbox(
              category['name'],
              category['id'],
              settings.enabledCategories.contains(category['id']),
              (value) {
                final newCategories = Set<String>.from(settings.enabledCategories);
                if (value) {
                  newCategories.add(category['id']);
                } else {
                  newCategories.remove(category['id']);
                }
                
                ref.read(userProfileProvider.notifier).updateSettings(
                  settings.copyWith(enabledCategories: newCategories)
                );
              },
              Colors.blue, // Use a default color since category doesn't have a color property
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryCheckbox(
    String label,
    String categoryId,
    bool isChecked,
    ValueChanged<bool> onChanged,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? color : color.withOpacity(0.3),
          width: isChecked ? 1.5 : 1,
        ),
        boxShadow: isChecked ? [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isChecked ? AppTheme.textBright : AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Checkbox(
            value: isChecked,
            onChanged: (value) => onChanged(value ?? false),
            activeColor: color,
            checkColor: Colors.black,
            side: BorderSide(color: color.withOpacity(0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionButton(
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color color = AppTheme.primaryNeon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppTheme.textSecondary,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataResetButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showResetConfirmation(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.red.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_rounded,
              color: Colors.red,
              size: 20,
            ),
            const SizedBox(width: 10),
            const Text(
              'Reset All Progress',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.red,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text(
          'Reset Progress',
          style: TextStyle(
            color: AppTheme.textBright,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'This will reset all your progress, statistics, and high scores. This action cannot be undone.',
          style: TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'CANCEL',
              style: TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Reset user profile to defaults
              ref.read(userProfileProvider.notifier).updateProfile(
                UserProfile.withDefaults()
              );
              Navigator.pop(context);
              
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All progress has been reset'),
                  backgroundColor: Colors.red.withOpacity(0.8),
                ),
              );
            },
            child: const Text(
              'RESET',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
