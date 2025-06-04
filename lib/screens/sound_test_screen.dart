import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/sound_service.dart';
import '../utils/theme.dart';

/// A screen that allows testing all the sound effects in the app
class SoundTestScreen extends ConsumerWidget {
  const SoundTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundService = ref.watch(soundServiceProvider);
    final isEnabled = soundService.settings.soundEnabled;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Sound Effects',
          style: TextStyle(
            color: AppTheme.textBright,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textBright),
          onPressed: () => context.go('/settings'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryNeon.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.primaryNeon,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sound Effect Gallery',
                          style: TextStyle(
                            color: AppTheme.primaryNeon,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the buttons below to preview each sound effect. ${!isEnabled ? "Sound effects are currently disabled in Settings." : ""}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Sound effect buttons
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildSoundButton(
                      'Button Tap',
                      Icons.touch_app,
                      Colors.blue,
                      () => soundService.playSound(SoundEffect.buttonTap),
                      isEnabled,
                    ),
                    _buildSoundButton(
                      'Card Entry',
                      Icons.credit_card,
                      Colors.green,
                      () => soundService.playSound(SoundEffect.cardEntry),
                      isEnabled,
                    ),
                    _buildSoundButton(
                      'Correct Answer',
                      Icons.check_circle,
                      Colors.green,
                      () => soundService.playCorrectFeedback(),
                      isEnabled,
                    ),
                    _buildSoundButton(
                      'Wrong Answer',
                      Icons.cancel,
                      Colors.red,
                      () => soundService.playWrongFeedback(),
                      isEnabled,
                    ),
                    _buildSoundButton(
                      'Swipe Action',
                      Icons.swipe,
                      AppTheme.primaryNeon,
                      () => soundService.playSound(SoundEffect.swipe),
                      isEnabled,
                    ),
                    _buildSoundButton(
                      'Snap Sound',
                      Icons.flash_on,
                      Colors.amber,
                      () => soundService.playSound(SoundEffect.snap),
                      isEnabled,
                    ),
                    _buildSoundButton(
                      'Streak Milestone',
                      Icons.emoji_events,
                      Colors.deepOrange,
                      () => soundService.playStreakMilestoneFeedback(),
                      isEnabled,
                    ),
                  ],
                ),
              ),
              
              // Haptic feedback section
              const SizedBox(height: 16),
              Text(
                'Haptic Feedback',
                style: TextStyle(
                  color: AppTheme.textBright,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildHapticButton(
                      'Light',
                      HapticFeedbackType.light,
                      Colors.lightBlue,
                      soundService,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildHapticButton(
                      'Medium',
                      HapticFeedbackType.medium,
                      Colors.blue,
                      soundService,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildHapticButton(
                      'Heavy',
                      HapticFeedbackType.heavy,
                      Colors.indigo,
                      soundService,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoundButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isEnabled,
  ) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        decoration: BoxDecoration(
          color: isEnabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isEnabled ? color : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? AppTheme.textBright : Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHapticButton(
    String label,
    HapticFeedbackType type,
    Color color,
    SoundService soundService,
  ) {
    final isEnabled = soundService.settings.hapticsEnabled;
    
    return GestureDetector(
      onTap: isEnabled ? () => soundService.playHaptic(type) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isEnabled ? color : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
