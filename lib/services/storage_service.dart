import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medical_models.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _gameStatsKey = 'game_stats';
  
  static SharedPreferences? _prefs;
  
  // Initialize shared preferences with better error handling
  static Future<void> init() async {
    try {
      if (_prefs != null) {
        print('SharedPreferences already initialized');
        return;
      }
      
      print('Initializing SharedPreferences...');
      _prefs = await SharedPreferences.getInstance();
      print('SharedPreferences initialized successfully');
      
      // Test write/read to verify it's working
      await _prefs!.setString('test_key', 'test_value');
      final testValue = _prefs!.getString('test_key');
      print('SharedPreferences test: ${testValue == 'test_value' ? 'PASSED' : 'FAILED'}');
    } catch (e) {
      print('ERROR initializing SharedPreferences: $e');
      // Try to recover by forcing a new instance
      _prefs = null;
      try {
        _prefs = await SharedPreferences.getInstance();
        print('SharedPreferences recovery successful');
      } catch (e2) {
        print('CRITICAL ERROR: SharedPreferences recovery failed: $e2');
      }
    }
  }
  
  // Save user profile with improved reliability
  static Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      // Force onboarding status to be saved directly first as a separate key
      // This provides a backup in case the full profile save fails
      await _saveOnboardingStatus(profile.hasCompletedOnboarding);
      
      // Ensure SharedPreferences is initialized
      if (_prefs == null) {
        print('STORAGE: SharedPreferences not initialized, initializing now');
        await init();
        if (_prefs == null) {
          print('STORAGE ERROR: Critical failure - SharedPreferences still null after init');
          return false;
        }
      }
      
      // Create a simplified map first with just the essential data
      final profileMap = {
        'highestStreak': profile.highestStreak,
        'currentStreak': profile.currentStreak,
        'hasCompletedOnboarding': profile.hasCompletedOnboarding,
        'lastPlayed': profile.lastPlayed?.toIso8601String(),
      };
      
      // Save the simplified map first
      final simpleJsonString = jsonEncode(profileMap);
      await _prefs!.setString('${_userProfileKey}_simple', simpleJsonString);
      
      // Now create the full profile map
      profileMap['questionsAnswered'] = profile.questionsAnswered.map((key, value) => 
        MapEntry(key.index.toString(), value));
      profileMap['categoryProgress'] = profile.categoryProgress;
      profileMap['settings'] = {
        'unitSystem': profile.settings.unitSystem.index,
        'difficulty': profile.settings.difficulty.index,
        'preferredSexContext': profile.settings.preferredSexContext.index,
        'soundEnabled': profile.settings.soundEnabled,
        'autoMode': profile.settings.autoMode,
        'enabledCategories': profile.settings.enabledCategories.toList(),
        'practiceMode': profile.settings.practiceMode,
        'preferredUnitSystem': profile.settings.preferredUnitSystem.index,
      };
      
      // Save the full profile
      final fullJsonString = jsonEncode(profileMap);
      final result = await _prefs!.setString(_userProfileKey, fullJsonString);
      
      // Verify the data was saved
      final verifyString = _prefs!.getString(_userProfileKey);
      if (verifyString == null) {
        print('STORAGE WARNING: Full user profile was not saved properly');
        return false;
      }
      
      print('STORAGE: User profile saved successfully: ${profile.hasCompletedOnboarding}');
      return result;
    } catch (e) {
      print('STORAGE ERROR: Error saving user profile: $e');
      return false;
    }
  }
  
  // Save onboarding status separately for reliability
  static Future<bool> _saveOnboardingStatus(bool completed) async {
    try {
      if (_prefs == null) await init();
      if (_prefs == null) return false;
      
      // Save onboarding status as a direct boolean
      final result = await _prefs!.setBool('onboarding_completed', completed);
      print('STORAGE: Onboarding status saved separately: $completed');
      return result;
    } catch (e) {
      print('STORAGE ERROR: Failed to save onboarding status: $e');
      return false;
    }
  }
  
  // Check onboarding status directly from storage
  // This is a synchronous method that returns the current onboarding status
  // Used by the router to make quick decisions without async operations
  static bool isOnboardingCompleted() {
    try {
      // If prefs isn't initialized, we can't check, so assume not completed
      if (_prefs == null) return false;
      
      // First try the direct boolean flag
      final directFlag = _prefs!.getBool('onboarding_completed');
      if (directFlag != null) {
        print('STORAGE: Direct onboarding flag found: $directFlag');
        return directFlag;
      }
      
      // If direct flag not found, try to parse from the full profile
      final profileString = _prefs!.getString(_userProfileKey);
      if (profileString != null) {
        try {
          final profileMap = jsonDecode(profileString) as Map<String, dynamic>;
          final hasCompleted = profileMap['hasCompletedOnboarding'] as bool? ?? false;
          print('STORAGE: Onboarding status from profile: $hasCompleted');
          return hasCompleted;
        } catch (e) {
          print('STORAGE ERROR: Failed to parse profile JSON: $e');
        }
      }
      
      // If we get here, we couldn't find any onboarding status
      return false;
    } catch (e) {
      print('STORAGE ERROR: Error checking onboarding status: $e');
      return false;
    }
  }
  
  // Load user profile
  static UserProfile loadUserProfile() {
    try {
      if (_prefs == null) {
        print('SharedPreferences not initialized for loadUserProfile, returning defaults');
        return UserProfile.withDefaults();
      }
      
      final profileString = _prefs!.getString(_userProfileKey);
      if (profileString == null) {
        print('No stored user profile found, returning defaults');
        return UserProfile.withDefaults();
      }
      
      final profileMap = jsonDecode(profileString) as Map<String, dynamic>;
      print('Successfully loaded profile data: $profileMap');
      
      // Get hasCompletedOnboarding directly first for debugging
      final hasCompleted = profileMap['hasCompletedOnboarding'] as bool? ?? false;
      print('Loaded onboarding completion status: $hasCompleted');
      
      // Check settings field exists
      if (!profileMap.containsKey('settings')) {
        print('Warning: Missing settings in stored profile');
        return UserProfile.withDefaults();
      }
      
      final settingsMap = profileMap['settings'] as Map<String, dynamic>;
      
      // Safe parsing of settings with fallbacks
      final unitSystemIndex = settingsMap['unitSystem'] as int? ?? 0;
      final difficultyIndex = settingsMap['difficulty'] as int? ?? 1; // Medium by default
      final sexContextIndex = settingsMap['preferredSexContext'] as int? ?? 2; // General by default
      final soundEnabled = settingsMap['soundEnabled'] as bool? ?? true;
      final autoMode = settingsMap['autoMode'] as bool? ?? false;
      final enabledCategories = settingsMap['enabledCategories'] != null
          ? Set<String>.from(settingsMap['enabledCategories'] as List)
          : <String>{};
      final practiceMode = settingsMap['practiceMode'] as bool? ?? false;
      final preferredUnitSystemIndex = settingsMap['preferredUnitSystem'] as int? ?? 0;
      
      final gameSettings = GameSettings(
        unitSystem: unitSystemIndex < UnitSystem.values.length 
            ? UnitSystem.values[unitSystemIndex] 
            : UnitSystem.si,
        difficulty: difficultyIndex < ParameterDifficulty.values.length 
            ? ParameterDifficulty.values[difficultyIndex] 
            : ParameterDifficulty.medium,
        preferredSexContext: sexContextIndex < SexContext.values.length 
            ? SexContext.values[sexContextIndex] 
            : SexContext.general,
        soundEnabled: soundEnabled,
        autoMode: autoMode,
        enabledCategories: enabledCategories,
        practiceMode: practiceMode,
        preferredUnitSystem: preferredUnitSystemIndex < UnitSystem.values.length 
            ? UnitSystem.values[preferredUnitSystemIndex] 
            : UnitSystem.si,
      );
      
      // Safe parsing of questions answered with fallbacks
      final questionsAnsweredMap = profileMap['questionsAnswered'] as Map<String, dynamic>? ?? {};
      final questionsAnswered = <ParameterDifficulty, int>{};
      
      questionsAnsweredMap.forEach((key, value) {
        try {
          final difficultyIndex = int.parse(key);
          if (difficultyIndex < ParameterDifficulty.values.length) {
            questionsAnswered[ParameterDifficulty.values[difficultyIndex]] = value as int;
          }
        } catch (e) {
          print('Error parsing question difficulty: $e');
        }
      });
      
      // Create user profile
      final profile = UserProfile(
        highestStreak: profileMap['highestStreak'] as int? ?? 0,
        currentStreak: profileMap['currentStreak'] as int? ?? 0,
        hasCompletedOnboarding: hasCompleted,
        lastPlayed: profileMap['lastPlayed'] != null 
            ? DateTime.tryParse(profileMap['lastPlayed'] as String) 
            : null,
        questionsAnswered: questionsAnswered,
        categoryProgress: profileMap['categoryProgress'] != null 
            ? Map<String, int>.from(profileMap['categoryProgress'] as Map)
            : {},
        settings: gameSettings,
      );
      
      print('Successfully loaded user profile with onboarding status: ${profile.hasCompletedOnboarding}');
      return profile;
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
