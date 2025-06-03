import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medical_models.dart';
import '../models/game_stats.dart';
import '../data/all_medical_parameters.dart';
import '../utils/unit_converter.dart';

class GameService extends StateNotifier<GameState> {
  final Random _random = Random();
  final List<MedicalParameter> _allParameters = allMedicalParameters;
  List<MedicalParameter> _currentPool = [];
  GameQuestion? _currentQuestion;
  UserProfile _userProfile;

  GameService(this._userProfile) : super(GameState()) {
    _initializeGame();
  }

  void _initializeGame() {
    _updateParameterPool();
    _generateNewQuestion();
  }

  void _updateParameterPool() {
    final difficulty = _getCurrentTargetDifficulty();
    
    if (_userProfile.shouldShowMixedDifficulty) {
      // After 80 questions, show all difficulties
      _currentPool = List.from(_allParameters);
    } else {
      // Show specific difficulty
      _currentPool = _allParameters
          .where((param) => param.difficulty == difficulty)
          .toList();
    }

    // Filter by enabled categories if in practice mode
    if (_userProfile.settings.practiceMode && 
        _userProfile.settings.enabledCategories.isNotEmpty) {
      _currentPool = _currentPool
          .where((param) => _userProfile.settings.enabledCategories
              .contains(param.categoryID))
          .toList();
    }
  }

  ParameterDifficulty _getCurrentTargetDifficulty() {
    if (_userProfile.shouldShowMixedDifficulty) {
      // Random difficulty for mixed mode
      final difficulties = ParameterDifficulty.values;
      return difficulties[_random.nextInt(difficulties.length)];
    }
    return _userProfile.getCurrentDifficulty();
  }

  void _generateNewQuestion() {
    if (_currentPool.isEmpty) {
      // Fallback to all parameters if pool is empty
      _currentPool = List.from(_allParameters);
    }

    final parameter = _currentPool[_random.nextInt(_currentPool.length)];
    
    // Determine unit system to use
    UnitSystem unitSystem = _userProfile.settings.unitSystem;
    if (_userProfile.settings.autoMode) {
      // Auto mode: randomly choose between SI and Conventional
      unitSystem = _random.nextBool() ? UnitSystem.si : UnitSystem.conventional;
    }

    // Determine sex context
    SexContext sexContext = _chooseSexContext(parameter, unitSystem);
    
    // Get unit data
    final unitData = parameter.getUnitData(unitSystem, sexContext);
    if (unitData == null) {
      // Fallback to any available unit
      if (parameter.units.isNotEmpty) {
        final fallbackUnit = parameter.units.first;
        _currentQuestion = _createQuestionFromUnit(parameter, fallbackUnit, SexContext.general);
      }
      return;
    }

    _currentQuestion = _createQuestionFromUnit(parameter, unitData, sexContext);
    
    state = state.copyWith(
      currentQuestion: _currentQuestion,
      isActive: true,
    );
  }

  SexContext _chooseSexContext(MedicalParameter parameter, UnitSystem unitSystem) {
    final availableContexts = parameter.getAvailableSexContexts(unitSystem);
    
    if (availableContexts.length == 1) {
      return availableContexts.first;
    }
    
    // If multiple contexts available, randomly choose
    // but prefer male/female over general for variety
    final specificContexts = availableContexts
        .where((context) => context != SexContext.general)
        .toList();
    
    if (specificContexts.isNotEmpty) {
      return specificContexts[_random.nextInt(specificContexts.length)];
    }
    
    return availableContexts[_random.nextInt(availableContexts.length)];
  }

  GameQuestion _createQuestionFromUnit(
    MedicalParameter parameter, 
    UnitData unitData, 
    SexContext sexContext
  ) {
    // Generate a value that's definitively in one of the three ranges
    final valueType = _chooseValueType();
    final value = _generateValueForType(valueType, unitData);
    
    return GameQuestion(
      parameter: parameter,
      value: value,
      unitData: unitData,
      sexContext: sexContext,
      correctAnswer: valueType,
      displayValue: unitData.formatValue(value),
    );
  }

  ValueType _chooseValueType() {
    // Equal probability for each type
    final types = ValueType.values;
    return types[_random.nextInt(types.length)];
  }

  double _generateValueForType(ValueType type, UnitData unitData) {
    final range = unitData.normalHigh - unitData.normalLow;
    final margin = range * 0.3; // 30% margin for clear distinction
    
    switch (type) {
      case ValueType.low:
        // Generate value clearly below normal range
        final maxLow = unitData.normalLow - (margin * 0.1);
        final minLow = maxLow - range;
        return _generateRandomDouble(minLow, maxLow, unitData.precision);
        
      case ValueType.normal:
        // Generate value clearly within normal range
        final marginAdjustedLow = unitData.normalLow + (margin * 0.1);
        final marginAdjustedHigh = unitData.normalHigh - (margin * 0.1);
        return _generateRandomDouble(marginAdjustedLow, marginAdjustedHigh, unitData.precision);
        
      case ValueType.high:
        // Generate value clearly above normal range
        final minHigh = unitData.normalHigh + (margin * 0.1);
        final maxHigh = minHigh + range;
        return _generateRandomDouble(minHigh, maxHigh, unitData.precision);
    }
  }

  double _generateRandomDouble(double min, double max, int precision) {
    if (min >= max) {
      // Fallback for edge cases
      return min;
    }
    
    final value = min + (_random.nextDouble() * (max - min));
    
    // Round to appropriate precision
    if (precision == 0) {
      return value.roundToDouble();
    } else {
      final factor = pow(10, precision).toDouble();
      return (value * factor).round() / factor;
    }
  }

  // Handle swipe actions
  void handleSwipe(SwipeDirection direction) {
    if (_currentQuestion == null) return;

    final isCorrect = _isSwipeCorrect(direction, _currentQuestion!.correctAnswer);
    
    if (isCorrect) {
      _handleCorrectAnswer();
    } else {
      _handleWrongAnswer();
    }
  }

  bool _isSwipeCorrect(SwipeDirection direction, ValueType correctAnswer) {
    switch (direction) {
      case SwipeDirection.left:
        return correctAnswer == ValueType.low;
      case SwipeDirection.right:
        return correctAnswer == ValueType.high;
      case SwipeDirection.up:
        return correctAnswer == ValueType.normal;
    }
  }

  void _handleCorrectAnswer() {
    final newStreak = state.currentStreak + 1;
    final newHighest = max(newStreak, _userProfile.highestStreak);
    
    // Update user profile
    _userProfile = _userProfile.copyWith(
      currentStreak: newStreak,
      highestStreak: newHighest,
      questionsAnswered: {
        ..._userProfile.questionsAnswered,
        _currentQuestion!.parameter.difficulty: 
            (_userProfile.questionsAnswered[_currentQuestion!.parameter.difficulty] ?? 0) + 1,
      },
      categoryProgress: {
        ..._userProfile.categoryProgress,
        _currentQuestion!.parameter.categoryID:
            (_userProfile.categoryProgress[_currentQuestion!.parameter.categoryID] ?? 0) + 1,
      },
      lastPlayed: DateTime.now(),
    );

    state = state.copyWith(
      currentStreak: newStreak,
      highestStreak: newHighest,
      lastAnswerCorrect: true,
    );

    // Generate next question after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _updateParameterPool(); // Update pool in case difficulty changed
      _generateNewQuestion();
    });
  }

  void _handleWrongAnswer() {
    // Reset streak but keep highest
    _userProfile = _userProfile.copyWith(
      currentStreak: 0,
      lastPlayed: DateTime.now(),
    );

    state = state.copyWith(
      currentStreak: 0,
      lastAnswerCorrect: false,
    );

    // Don't generate new question - let user try again
  }

  // Toggle unit system during gameplay
  void toggleUnitSystem() {
    if (_currentQuestion == null) return;

    final currentSystem = _currentQuestion!.unitData.unitType;
    final newSystem = currentSystem == UnitSystem.si 
        ? UnitSystem.conventional 
        : UnitSystem.si;

    // Convert current question to new unit system
    final convertedQuestion = UnitConverter.convertQuestion(_currentQuestion!, newSystem);
    
    _currentQuestion = convertedQuestion;
    
    // Update user settings
    _userProfile = _userProfile.copyWith(
      settings: _userProfile.settings.copyWith(
        unitSystem: newSystem,
        autoMode: false, // Disable auto mode when manually toggling
      ),
    );

    state = state.copyWith(
      currentQuestion: convertedQuestion,
    );
  }

  // Get current question
  GameQuestion? get currentQuestion => _currentQuestion;

  // Get user profile
  UserProfile get userProfile => _userProfile;

  // Update settings
  void updateSettings(GameSettings newSettings) {
    _userProfile = _userProfile.copyWith(settings: newSettings);
    
    // Regenerate question if unit system changed
    if (_currentQuestion != null && 
        newSettings.unitSystem != _currentQuestion!.unitData.unitType &&
        !newSettings.autoMode) {
      final convertedQuestion = UnitConverter.convertQuestion(
        _currentQuestion!, 
        newSettings.unitSystem
      );
      _currentQuestion = convertedQuestion;
      
      state = state.copyWith(currentQuestion: convertedQuestion);
    }
  }

  // Start new game
  void startNewGame() {
    _initializeGame();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalQuestions': _userProfile.totalQuestionsAnswered,
      'currentStreak': state.currentStreak,
      'highestStreak': _userProfile.highestStreak,
      'difficultyBreakdown': _userProfile.questionsAnswered,
      'categoryProgress': _userProfile.categoryProgress,
      'currentDifficulty': _userProfile.getCurrentDifficulty().toString(),
      'mixedMode': _userProfile.shouldShowMixedDifficulty,
    };
  }
}

// Game state model
class GameState {
  final GameQuestion? currentQuestion;
  final GameSettings settings;
  final int currentStreak;
  final int highestStreak;
  final bool isActive;
  final bool? lastAnswerCorrect;
  final bool isPracticeMode;
  final GameStats stats;

  GameState({
    this.currentQuestion,
    GameSettings? settings,
    this.currentStreak = 0,
    this.highestStreak = 0,
    this.isActive = false,
    this.lastAnswerCorrect,
    this.isPracticeMode = false,
    GameStats? stats,
  }) : this.settings = settings ?? GameSettings(),
       this.stats = stats ?? GameStats();

  GameState copyWith({
    GameQuestion? currentQuestion,
    GameSettings? settings,
    int? currentStreak,
    int? highestStreak,
    bool? isActive,
    bool? lastAnswerCorrect,
    bool? isPracticeMode,
    GameStats? stats,
  }) {
    return GameState(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      settings: settings ?? this.settings,
      currentStreak: currentStreak ?? this.currentStreak,
      highestStreak: highestStreak ?? this.highestStreak,
      isActive: isActive ?? this.isActive,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      isPracticeMode: isPracticeMode ?? this.isPracticeMode,
      stats: stats ?? this.stats,
    );
  }
}

// Providers
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});

final gameServiceProvider = StateNotifierProvider<GameService, GameState>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  return GameService(userProfile);
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile.withDefaults());

  void updateProfile(UserProfile newProfile) {
    state = newProfile;
  }

  void updateSettings(GameSettings newSettings) {
    state = state.copyWith(settings: newSettings);
  }

  void resetStreak() {
    state = state.copyWith(currentStreak: 0);
  }

  void incrementStreak() {
    final newStreak = state.currentStreak + 1;
    state = state.copyWith(
      currentStreak: newStreak,
      highestStreak: max(newStreak, state.highestStreak),
    );
  }
}
