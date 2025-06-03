import 'dart:convert';

// Define enums for user settings
enum UnitSystem { si, conventional }
enum SexContext { male, female, general }
enum Difficulty { easy, medium, hard }

class UserProfile {
  final bool hasCompletedOnboarding;
  final UserSettings settings;
  final UserStats stats;

  UserProfile({
    this.hasCompletedOnboarding = false,
    UserSettings? settings,
    UserStats? stats,
  }) : 
    settings = settings ?? UserSettings(),
    stats = stats ?? UserStats();

  UserProfile copyWith({
    bool? hasCompletedOnboarding,
    UserSettings? settings,
    UserStats? stats,
  }) {
    return UserProfile(
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'settings': settings.toJson(),
      'stats': stats.toJson(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      settings: UserSettings.fromJson(json['settings'] as Map<String, dynamic>? ?? {}),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
    );
  }

  static UserProfile fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    return UserProfile.fromJson(decoded as Map<String, dynamic>);
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class UserSettings {
  final UnitSystem unitSystem;
  final SexContext sexContext;
  final Difficulty difficulty;
  final bool soundEnabled;
  final bool autoMode;
  final Map<String, bool> enabledCategories;

  UserSettings({
    this.unitSystem = UnitSystem.si,
    this.sexContext = SexContext.general,
    this.difficulty = Difficulty.medium,
    this.soundEnabled = true,
    this.autoMode = false,
    Map<String, bool>? enabledCategories,
  }) : enabledCategories = enabledCategories ?? {};

  UserSettings copyWith({
    UnitSystem? unitSystem,
    SexContext? sexContext,
    Difficulty? difficulty,
    bool? soundEnabled,
    bool? autoMode,
    Map<String, bool>? enabledCategories,
  }) {
    return UserSettings(
      unitSystem: unitSystem ?? this.unitSystem,
      sexContext: sexContext ?? this.sexContext,
      difficulty: difficulty ?? this.difficulty,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoMode: autoMode ?? this.autoMode,
      enabledCategories: enabledCategories ?? this.enabledCategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unitSystem': unitSystem.index,
      'sexContext': sexContext.index,
      'difficulty': difficulty.index,
      'soundEnabled': soundEnabled,
      'autoMode': autoMode,
      'enabledCategories': enabledCategories,
    };
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final enabledCategoriesJson = json['enabledCategories'];
    final enabledCategories = <String, bool>{};
    
    if (enabledCategoriesJson != null && enabledCategoriesJson is Map) {
      enabledCategoriesJson.forEach((key, value) {
        if (value is bool) {
          enabledCategories[key.toString()] = value;
        }
      });
    }

    return UserSettings(
      unitSystem: UnitSystem.values[json['unitSystem'] as int? ?? 0],
      sexContext: SexContext.values[json['sexContext'] as int? ?? 0],
      difficulty: Difficulty.values[json['difficulty'] as int? ?? 1],
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      autoMode: json['autoMode'] as bool? ?? false,
      enabledCategories: enabledCategories,
    );
  }
}

class UserStats {
  final int bestStreak;
  final int totalGamesPlayed;
  final Map<String, int> categoryCorrect;
  final Map<String, int> categoryTotal;

  UserStats({
    this.bestStreak = 0,
    this.totalGamesPlayed = 0,
    Map<String, int>? categoryCorrect,
    Map<String, int>? categoryTotal,
  }) :
    categoryCorrect = categoryCorrect ?? {},
    categoryTotal = categoryTotal ?? {};

  UserStats copyWith({
    int? bestStreak,
    int? totalGamesPlayed,
    Map<String, int>? categoryCorrect,
    Map<String, int>? categoryTotal,
  }) {
    return UserStats(
      bestStreak: bestStreak ?? this.bestStreak,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      categoryCorrect: categoryCorrect ?? this.categoryCorrect,
      categoryTotal: categoryTotal ?? this.categoryTotal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bestStreak': bestStreak,
      'totalGamesPlayed': totalGamesPlayed,
      'categoryCorrect': categoryCorrect,
      'categoryTotal': categoryTotal,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final categoryCorrect = <String, int>{};
    final categoryTotal = <String, int>{};

    if (json['categoryCorrect'] is Map) {
      (json['categoryCorrect'] as Map).forEach((key, value) {
        if (value is int) {
          categoryCorrect[key.toString()] = value;
        }
      });
    }

    if (json['categoryTotal'] is Map) {
      (json['categoryTotal'] as Map).forEach((key, value) {
        if (value is int) {
          categoryTotal[key.toString()] = value;
        }
      });
    }

    return UserStats(
      bestStreak: json['bestStreak'] as int? ?? 0,
      totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
      categoryCorrect: categoryCorrect,
      categoryTotal: categoryTotal,
    );
  }
}
