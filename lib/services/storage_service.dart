import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medical_models.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _gameStatsKey = 'game_stats';
  
  static SharedPreferences? _prefs;
  
  // Initialize shared preferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Save user profile
  static Future<bool> saveUserProfile(UserProfile profile) async {
    if (_prefs == null) await init();
    
    final profileMap = {
      'highestStreak': profile.highestStreak,
      'currentStreak': profile.currentStreak,
      'hasCompletedOnboarding': profile.hasCompletedOnboarding,
      'lastPlayed': profile.lastPlayed?.toIso8601String(),
      'questionsAnswered': profile.questionsAnswered.map((key, value) => 
        MapEntry(key.index.toString(), value)),
      'categoryProgress': profile.categoryProgress,
      'settings': {
        'unitSystem': profile.settings.unitSystem.index,
        'difficulty': profile.settings.difficulty.index,
        'preferredSexContext': profile.settings.preferredSexContext.index,
        'soundEnabled': profile.settings.soundEnabled,
        'autoMode': profile.settings.autoMode,
        'enabledCategories': profile.settings.enabledCategories.toList(),
        'practiceMode': profile.settings.practiceMode,
        'preferredUnitSystem': profile.settings.preferredUnitSystem.index,
      },
    };
    
    return await _prefs!.setString(_userProfileKey, jsonEncode(profileMap));
  }
  
  // Load user profile
  static UserProfile loadUserProfile() {
    if (_prefs == null) {
      return UserProfile.withDefaults();
    }
    
    final profileString = _prefs!.getString(_userProfileKey);
    if (profileString == null) {
      return UserProfile.withDefaults();
    }
    
    try {
      final profileMap = jsonDecode(profileString) as Map<String, dynamic>;
      
      final settingsMap = profileMap['settings'] as Map<String, dynamic>;
      final gameSettings = GameSettings(
        unitSystem: UnitSystem.values[settingsMap['unitSystem'] as int],
        difficulty: ParameterDifficulty.values[settingsMap['difficulty'] as int],
        preferredSexContext: SexContext.values[settingsMap['preferredSexContext'] as int],
        soundEnabled: settingsMap['soundEnabled'] as bool,
        autoMode: settingsMap['autoMode'] as bool,
        enabledCategories: Set<String>.from(settingsMap['enabledCategories'] as List),
        practiceMode: settingsMap['practiceMode'] as bool,
        preferredUnitSystem: UnitSystem.values[settingsMap['preferredUnitSystem'] as int],
      );
      
      final questionsAnswered = (profileMap['questionsAnswered'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
              ParameterDifficulty.values[int.parse(key)], value as int));
      
      return UserProfile(
        highestStreak: profileMap['highestStreak'] as int,
        currentStreak: profileMap['currentStreak'] as int,
        hasCompletedOnboarding: profileMap['hasCompletedOnboarding'] as bool,
        lastPlayed: profileMap['lastPlayed'] != null 
            ? DateTime.parse(profileMap['lastPlayed'] as String) 
            : null,
        questionsAnswered: questionsAnswered,
        categoryProgress: Map<String, int>.from(profileMap['categoryProgress'] as Map),
        settings: gameSettings,
      );
    } catch (e) {
      // If there's an error parsing, return default profile
      print('Error loading user profile: $e');
      return UserProfile.withDefaults();
    }
  }
  
  // Save game stats
  static Future<bool> saveGameStats(GamePerformance stats) async {
    if (_prefs == null) await init();
    
    final statsMap = {
      'totalQuestions': stats.totalQuestions,
      'correctAnswers': stats.correctAnswers,
      'currentStreak': stats.currentStreak,
      'bestStreak': stats.bestStreak,
      'answeredByDifficulty': stats.answeredByDifficulty.map((key, value) => 
        MapEntry(key.index.toString(), value)),
      'correctByDifficulty': stats.correctByDifficulty.map((key, value) => 
        MapEntry(key.index.toString(), value)),
    };
    
    return await _prefs!.setString(_gameStatsKey, jsonEncode(statsMap));
  }
  
  // Load game stats
  static GamePerformance loadGameStats() {
    if (_prefs == null) {
      return GamePerformance();
    }
    
    final statsString = _prefs!.getString(_gameStatsKey);
    if (statsString == null) {
      return GamePerformance();
    }
    
    try {
      final statsMap = jsonDecode(statsString) as Map<String, dynamic>;
      
      final answeredByDifficulty = (statsMap['answeredByDifficulty'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
              ParameterDifficulty.values[int.parse(key)], value as int));
      
      final correctByDifficulty = (statsMap['correctByDifficulty'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(
              ParameterDifficulty.values[int.parse(key)], value as int));
      
      return GamePerformance(
        totalQuestions: statsMap['totalQuestions'] as int,
        correctAnswers: statsMap['correctAnswers'] as int,
        currentStreak: statsMap['currentStreak'] as int,
        bestStreak: statsMap['bestStreak'] as int,
        answeredByDifficulty: answeredByDifficulty,
        correctByDifficulty: correctByDifficulty,
      );
    } catch (e) {
      // If there's an error parsing, return default stats
      print('Error loading game stats: $e');
      return GamePerformance();
    }
  }
  
  // Clear all data (for testing)
  static Future<void> clearAllData() async {
    if (_prefs == null) await init();
    await _prefs!.clear();
  }
}
