// Enhanced medical parameter models
enum ParameterDifficulty { 
  easy, 
  medium, 
  hard, 
  legendary 
}

enum SexContext { 
  general, 
  male, 
  female 
}

enum UnitSystem { 
  conventional, 
  si 
}

enum SwipeDirection { 
  left, 
  right, 
  up 
}

enum ValueType { 
  low, 
  normal, 
  high 
}

class UnitData {
  final UnitSystem unitType;
  final String unitSymbol;
  final double normalLow;
  final double normalHigh;
  final int precision;
  final SexContext sexContext;
  final double? conversionFactorToPrimarySI;
  final bool isDefaultDisplayForType;

  UnitData({
    required this.unitType,
    required this.unitSymbol,
    required this.normalLow,
    required this.normalHigh,
    required this.precision,
    required this.sexContext,
    this.conversionFactorToPrimarySI,
    required this.isDefaultDisplayForType,
  });
}

class MedicalParameter {
  final String id;
  final String name;
  final String categoryID;
  final String categoryName;
  final ParameterDifficulty difficulty;
  final bool isProModuleParameter;
  final String explanation;
  final bool higherIsBetter;
  final List<UnitData> units;

  MedicalParameter({
    required this.id,
    required this.name,
    required this.categoryID,
    required this.categoryName,
    required this.difficulty,
    this.isProModuleParameter = false,
    required this.explanation,
    required this.higherIsBetter,
    required this.units,
  });

  // Get unit data for specific system and sex context
  UnitData? getUnitData(UnitSystem unitSystem, SexContext sexContext) {
    // First try to find exact match
    final exactMatch = units.where((unit) => 
        unit.unitType == unitSystem && 
        unit.sexContext == sexContext).firstOrNull;
    
    if (exactMatch != null) return exactMatch;
    
    // If no exact match, try general sex context
    final generalMatch = units.where((unit) => 
        unit.unitType == unitSystem && 
        unit.sexContext == SexContext.general).firstOrNull;
    
    if (generalMatch != null) return generalMatch;
    
    // If still no match, get default for unit system
    return units.where((unit) => 
        unit.unitType == unitSystem && 
        unit.isDefaultDisplayForType).firstOrNull;
  }

  // Get all available sex contexts for this parameter
  List<SexContext> getAvailableSexContexts(UnitSystem unitSystem) {
    return units
        .where((unit) => unit.unitType == unitSystem)
        .map((unit) => unit.sexContext)
        .toSet()
        .toList();
  }

  // Check if parameter has sex-specific ranges
  bool hasSexSpecificRanges(UnitSystem unitSystem) {
    final contexts = getAvailableSexContexts(unitSystem);
    return contexts.length > 1 || 
           (contexts.length == 1 && contexts.first != SexContext.general);
  }
}

class GameQuestion {
  final MedicalParameter parameter;
  final double value;
  final UnitData unitData;
  final SexContext sexContext;
  final ValueType correctAnswer;
  final String displayValue;

  GameQuestion({
    required this.parameter,
    required this.value,
    required this.unitData,
    required this.sexContext,
    required this.correctAnswer,
    required this.displayValue,
  });
}

class GameSettings {
  final UnitSystem unitSystem;
  final ParameterDifficulty difficulty;
  final SexContext preferredSexContext;
  final bool soundEnabled;
  final bool autoMode; // Automatically choose best unit system
  final Set<String> enabledCategories;
  final bool practiceMode;
  final UnitSystem preferredUnitSystem;

  GameSettings({
    this.unitSystem = UnitSystem.conventional,
    this.difficulty = ParameterDifficulty.easy,
    this.preferredSexContext = SexContext.general,
    this.soundEnabled = true,
    this.autoMode = true,
    this.enabledCategories = const {},
    this.practiceMode = false,
    this.preferredUnitSystem = UnitSystem.conventional,
  });

  GameSettings copyWith({
    UnitSystem? unitSystem,
    ParameterDifficulty? difficulty,
    SexContext? preferredSexContext,
    bool? soundEnabled,
    bool? autoMode,
    Set<String>? enabledCategories,
    bool? practiceMode,
    UnitSystem? preferredUnitSystem,
  }) {
    return GameSettings(
      unitSystem: unitSystem ?? this.unitSystem,
      difficulty: difficulty ?? this.difficulty,
      preferredSexContext: preferredSexContext ?? this.preferredSexContext,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoMode: autoMode ?? this.autoMode,
      enabledCategories: enabledCategories ?? this.enabledCategories,
      practiceMode: practiceMode ?? this.practiceMode,
      preferredUnitSystem: preferredUnitSystem ?? this.preferredUnitSystem,
    );
  }
}

class UserProfile {
  final int highestStreak;
  final int currentStreak;
  final GameSettings settings;
  final bool hasCompletedOnboarding;
  final Map<ParameterDifficulty, int> questionsAnswered;
  final Map<String, int> categoryProgress;
  final DateTime? lastPlayed;

  // Factory constructor with default settings
  factory UserProfile.withDefaults() {
    return UserProfile(
      settings: GameSettings(),
    );
  }

  UserProfile({
    this.highestStreak = 0,
    this.currentStreak = 0,
    required this.settings,
    this.hasCompletedOnboarding = false,
    this.questionsAnswered = const {},
    this.categoryProgress = const {},
    this.lastPlayed,
  });



  UserProfile copyWith({
    int? highestStreak,
    int? currentStreak,
    GameSettings? settings,
    bool? hasCompletedOnboarding,
    Map<ParameterDifficulty, int>? questionsAnswered,
    Map<String, int>? categoryProgress,
    DateTime? lastPlayed,
  }) {
    return UserProfile(
      highestStreak: highestStreak ?? this.highestStreak,
      currentStreak: currentStreak ?? this.currentStreak,
      settings: settings ?? this.settings,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      categoryProgress: categoryProgress ?? this.categoryProgress,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  // Calculate total questions answered
  int get totalQuestionsAnswered {
    return questionsAnswered.values.fold(0, (sum, count) => sum + count);
  }

  // Get current difficulty level based on progress
  ParameterDifficulty getCurrentDifficulty() {
    final total = totalQuestionsAnswered;
    if (total < 20) return ParameterDifficulty.easy;
    if (total < 40) return ParameterDifficulty.medium;
    if (total < 60) return ParameterDifficulty.hard;
    if (total < 80) return ParameterDifficulty.legendary;
    return ParameterDifficulty.easy; // Mixed after 80
  }

  // Check if should show mixed difficulty
  bool get shouldShowMixedDifficulty => totalQuestionsAnswered >= 80;
}

// Extension methods for better usability
extension UnitDataExtensions on UnitData {
  // Format value according to precision
  String formatValue(double value) {
    return value.toStringAsFixed(precision);
  }

  // Check if value is in normal range
  bool isValueNormal(double value) {
    return value >= normalLow && value <= normalHigh;
  }

  // Check if value is low
  bool isValueLow(double value) {
    return value < normalLow;
  }

  // Check if value is high
  bool isValueHigh(double value) {
    return value > normalHigh;
  }

  // Get value type
  ValueType getValueType(double value) {
    if (isValueLow(value)) return ValueType.low;
    if (isValueHigh(value)) return ValueType.high;
    return ValueType.normal;
  }
}

extension MedicalParameterExtensions on MedicalParameter {
  // Convert value between unit systems
  double convertValue(double value, UnitSystem fromSystem, UnitSystem toSystem, SexContext sexContext) {
    if (fromSystem == toSystem) return value;
    
    final fromUnit = getUnitData(fromSystem, sexContext);
    final toUnit = getUnitData(toSystem, sexContext);
    
    if (fromUnit == null || toUnit == null) return value;
    
    // Convert using conversion factors
    if (fromSystem == UnitSystem.conventional && toSystem == UnitSystem.si) {
      return value * (toUnit.conversionFactorToPrimarySI ?? 1.0);
    } else if (fromSystem == UnitSystem.si && toSystem == UnitSystem.conventional) {
      return value / (fromUnit.conversionFactorToPrimarySI ?? 1.0);
    }
    
    return value;
  }
}

// Game Statistics Class
class GamePerformance {
  final int totalQuestions;
  final int correctAnswers;
  final int currentStreak;
  final int bestStreak;
  final Map<ParameterDifficulty, int> answeredByDifficulty;
  final Map<ParameterDifficulty, int> correctByDifficulty;
  
  GamePerformance({
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.answeredByDifficulty = const {},
    this.correctByDifficulty = const {},
  });
  
  double get accuracy => totalQuestions > 0 ? correctAnswers / totalQuestions : 0.0;
  
  Map<ParameterDifficulty, double> get accuracyByDifficulty {
    final result = <ParameterDifficulty, double>{};
    for (final difficulty in ParameterDifficulty.values) {
      final answered = answeredByDifficulty[difficulty] ?? 0;
      final correct = correctByDifficulty[difficulty] ?? 0;
      result[difficulty] = answered > 0 ? correct / answered : 0.0;
    }
    return result;
  }
  
  GamePerformance copyWith({
    int? totalQuestions,
    int? correctAnswers,
    int? currentStreak,
    int? bestStreak,
    Map<ParameterDifficulty, int>? answeredByDifficulty,
    Map<ParameterDifficulty, int>? correctByDifficulty,
  }) {
    return GamePerformance(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      answeredByDifficulty: answeredByDifficulty ?? this.answeredByDifficulty,
      correctByDifficulty: correctByDifficulty ?? this.correctByDifficulty,
    );
  }
}

// Utility functions for unit formatting
class UnitFormatter {
  static String formatValueWithUnit(double value, UnitData unitData) {
    return '${unitData.formatValue(value)} ${unitData.unitSymbol}';
  }
}
