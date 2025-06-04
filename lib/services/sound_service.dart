import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum representing the available sound effects in the application
enum SoundEffect {
  buttonTap,
  cardEntry,
  correct,
  wrong,
  snap,
  swipe,
  streakMilestone,
}

/// Provider for the SoundService
final soundServiceProvider = Provider<SoundService>((ref) => SoundService());

/// State class for sound settings
class SoundSettings {
  final bool soundEnabled;
  final bool hapticsEnabled;
  final double volume;

  const SoundSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.volume = 1.0,
  });

  SoundSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    double? volume,
  }) {
    return SoundSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      volume: volume ?? this.volume,
    );
  }

  // Convenience method to check if all audio feedback is disabled
  bool get isAllAudioDisabled => !soundEnabled && !hapticsEnabled;
}

/// Service responsible for playing sound effects and providing haptic feedback
class SoundService {
  // Cache of audio players for each sound effect
  final Map<SoundEffect, AudioPlayer> _audioPlayers = {};
  
  // Paths to the sound files
  final Map<SoundEffect, String> _soundPaths = {
    SoundEffect.buttonTap: 'sounds/button_tap.wav',
    SoundEffect.cardEntry: 'sounds/card_entry.wav',
    SoundEffect.correct: 'sounds/correct.wav',
    SoundEffect.wrong: 'sounds/wrong.wav',
    SoundEffect.snap: 'sounds/snap.wav',
    SoundEffect.swipe: 'sounds/swipe.wav',
    SoundEffect.streakMilestone: 'sounds/streak_milestone.wav',
  };

  // Current settings
  SoundSettings _settings = const SoundSettings();
  SoundSettings get settings => _settings;

  // Initialize the service
  Future<void> initialize() async {
    await _loadSettings();
    
    // Preload commonly used sounds for faster playback
    await Future.wait([
      _preloadSound(SoundEffect.buttonTap),
      _preloadSound(SoundEffect.swipe),
    ]);
  }

  // Load settings from shared preferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _settings = SoundSettings(
        soundEnabled: prefs.getBool('soundEnabled') ?? true,
        hapticsEnabled: prefs.getBool('hapticsEnabled') ?? true,
        volume: prefs.getDouble('soundVolume') ?? 1.0,
      );
    } catch (e) {
      debugPrint('Failed to load sound settings: $e');
    }
  }

  // Save settings to shared preferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('soundEnabled', _settings.soundEnabled);
      await prefs.setBool('hapticsEnabled', _settings.hapticsEnabled);
      await prefs.setDouble('soundVolume', _settings.volume);
    } catch (e) {
      debugPrint('Failed to save sound settings: $e');
    }
  }

  // Update settings
  Future<void> updateSettings(SoundSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
  }

  // Toggle sound on/off
  Future<void> toggleSound() async {
    _settings = _settings.copyWith(soundEnabled: !_settings.soundEnabled);
    await _saveSettings();
  }

  // Toggle haptics on/off
  Future<void> toggleHaptics() async {
    _settings = _settings.copyWith(hapticsEnabled: !_settings.hapticsEnabled);
    await _saveSettings();
  }

  // Set volume level
  Future<void> setVolume(double volume) async {
    if (volume < 0.0 || volume > 1.0) {
      throw ArgumentError('Volume must be between 0.0 and 1.0');
    }
    _settings = _settings.copyWith(volume: volume);
    await _saveSettings();
  }

  // Preload a sound for faster playback
  Future<void> _preloadSound(SoundEffect effect) async {
    if (!_settings.soundEnabled) return;
    
    try {
      final player = AudioPlayer();
      await player.setSource(AssetSource(_soundPaths[effect]!));
      await player.setVolume(_settings.volume);
      _audioPlayers[effect] = player;
    } catch (e) {
      debugPrint('Failed to preload sound $effect: $e');
    }
  }

  // Play a sound effect
  Future<void> playSound(SoundEffect effect) async {
    if (!_settings.soundEnabled) return;
    
    try {
      // Get or create an audio player for this effect
      AudioPlayer? player = _audioPlayers[effect];
      
      if (player == null) {
        player = AudioPlayer();
        await player.setSource(AssetSource(_soundPaths[effect]!));
      }
      
      // Set volume and play
      await player.setVolume(_settings.volume);
      await player.play(AssetSource(_soundPaths[effect]!), mode: PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('Failed to play sound $effect: $e');
    }
  }

  // Play haptic feedback
  void playHaptic(HapticFeedbackType type) {
    if (!_settings.hapticsEnabled) return;
    
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.vibrate:
        HapticFeedback.vibrate();
        break;
    }
  }

  // Combined method to play both sound and haptic feedback
  Future<void> playFeedback(SoundEffect sound, HapticFeedbackType haptic) async {
    // Execute in parallel for immediate feedback
    await Future.wait([
      playSound(sound),
      Future(() => playHaptic(haptic)),
    ]);
  }

  // Special method for correct answer feedback
  Future<void> playCorrectFeedback() async {
    await playFeedback(SoundEffect.correct, HapticFeedbackType.medium);
  }

  // Special method for wrong answer feedback
  Future<void> playWrongFeedback() async {
    await playFeedback(SoundEffect.wrong, HapticFeedbackType.heavy);
  }

  // Special method for streak milestone feedback
  Future<void> playStreakMilestoneFeedback() async {
    await playFeedback(SoundEffect.streakMilestone, HapticFeedbackType.medium);
  }

  // Dispose of resources
  void dispose() {
    for (final player in _audioPlayers.values) {
      player.dispose();
    }
    _audioPlayers.clear();
  }
}

/// Enum representing different haptic feedback types
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  vibrate,
}
