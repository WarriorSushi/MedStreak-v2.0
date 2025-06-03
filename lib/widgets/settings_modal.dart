import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../utils/theme.dart';
import '../services/game_service.dart';
import '../models/medical_models.dart';

class SettingsModal extends ConsumerWidget {
  const SettingsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameServiceProvider);
    final gameService = ref.read(gameServiceProvider.notifier);
    final settings = gameState.settings;
    
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
              color: AppTheme.secondaryNeon.withOpacity(0.3),
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
                    'Settings',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textBright,
                      shadows: [
                        Shadow(
                          color: AppTheme.secondaryNeon.withOpacity(0.5),
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
            // Settings options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Difficulty setting
                  _buildSettingSection(
                    title: 'Difficulty',
                    child: _buildDifficultySelector(settings.difficulty, (difficulty) {
                      final newSettings = settings.copyWith(difficulty: difficulty);
                      gameService.updateSettings(newSettings);
                    }),
                  ),
                  
                  // Unit system preference
                  _buildSettingSection(
                    title: 'Preferred Unit System',
                    child: _buildUnitSystemSelector(settings.preferredUnitSystem, (unitSystem) {
                      final newSettings = settings.copyWith(preferredUnitSystem: unitSystem);
                      gameService.updateSettings(newSettings);
                    }),
                  ),
                  
                  // Sex context filter
                  _buildSettingSection(
                    title: 'Sex Context',
                    child: _buildSexContextSelector(settings.preferredSexContext, (sexContext) {
                      final newSettings = settings.copyWith(preferredSexContext: sexContext);
                      gameService.updateSettings(newSettings);
                    }),
                  ),
                  
                  // Practice mode toggle
                  _buildSettingSection(
                    title: 'Practice Mode',
                    description: 'No streak counting, focus on learning',
                    child: Switch(
                      value: settings.practiceMode,
                      onChanged: (value) {
                        final newSettings = settings.copyWith(practiceMode: value);
                        gameService.updateSettings(newSettings);
                      },
                      activeColor: AppTheme.secondaryNeon,
                      activeTrackColor: AppTheme.secondaryNeon.withOpacity(0.3),
                    ),
                  ),
                  
                  // About section
                  const SizedBox(height: 20),
                  _buildAboutSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSettingSection({
    required String title,
    String? description,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textBright,
            ),
          ),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
  
  Widget _buildDifficultySelector(
    ParameterDifficulty currentDifficulty,
    Function(ParameterDifficulty) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: ParameterDifficulty.values.map((difficulty) {
        final isSelected = difficulty == currentDifficulty;
        final color = isSelected ? AppTheme.primaryNeon : AppTheme.textSecondary;
        final bgColor = isSelected
            ? AppTheme.primaryNeon.withOpacity(0.2)
            : AppTheme.cardDark;
            
        return GestureDetector(
          onTap: () => onChanged(difficulty),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              difficulty.name.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUnitSystemSelector(
    UnitSystem currentSystem,
    Function(UnitSystem) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: UnitSystem.values.map((system) {
        final isSelected = system == currentSystem;
        final color = isSelected ? AppTheme.secondaryNeon : AppTheme.textSecondary;
        final bgColor = isSelected
            ? AppTheme.secondaryNeon.withOpacity(0.2)
            : AppTheme.cardDark;
            
        return GestureDetector(
          onTap: () => onChanged(system),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Text(
              system.name.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSexContextSelector(
    SexContext currentContext,
    Function(SexContext) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: SexContext.values.map((context) {
        final isSelected = context == currentContext;
        final color = isSelected ? AppTheme.primaryNeon : AppTheme.textSecondary;
        final bgColor = isSelected
            ? AppTheme.primaryNeon.withOpacity(0.2)
            : AppTheme.cardDark;
            
        // Get display text for the context
        String displayText;
        IconData icon;
        
        switch (context) {
          case SexContext.male:
            displayText = 'MALE';
            icon = Icons.male;
            break;
          case SexContext.female:
            displayText = 'FEMALE';
            icon = Icons.female;
            break;
          case SexContext.general:
            displayText = 'ALL';
            icon = Icons.people;
            break;
        }
        
        return GestureDetector(
          onTap: () => onChanged(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.dividerDark,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo animation
              SizedBox(
                width: 30,
                height: 30,
                child: Lottie.asset(
                  'assets/lottie/logo.json',
                  repeat: true,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'MedStreak',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textBright,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Version 1.0.0',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 5),
          const Text(
            'A flashcard-style game to help medical students master lab values and reference ranges.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 15),
          // Credits section
          const Text(
            '© 2025 MedStreak',
            style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
