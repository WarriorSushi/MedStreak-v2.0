import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medical_models.dart';
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
      displayValue: value.toStringAsFixed(unitData.precision),
    );
  }

  ValueType _chooseValueType() {
    final types = ValueType.values;
    return types[_random.nextInt(types.length)];
  }

  double _generateValueForType(ValueType type, UnitData unitData) {
    switch (type) {
      case ValueType.normal:
        // Generate a value within the normal range
        return _generateRandomDouble(
          unitData.normalLow, 
          unitData.normalHigh,
          unitData.precision
        );

      case ValueType.low:
        // Generate a value below the normal range
        final min = unitData.normalLow * 0.5; // 50% of normal low
        final max = unitData.normalLow * 0.95; // Just below normal
        return _generateRandomDouble(min, max, unitData.precision);

      case ValueType.high:
        // Generate a value above the normal range
        final min = unitData.normalHigh * 1.05; // Just above normal
        final max = unitData.normalHigh * 1.5; // 150% of normal high
        return _generateRandomDouble(min, max, unitData.precision);
    }
  }

  double _generateRandomDouble(double min, double max, int precision) {
    if (min >= max) {
      // Safety check - shouldn't happen with properly configured parameters
      min = max * 0.8;
    }

    // Generate random double
    final value = min + _random.nextDouble() * (max - min);
    
    // Round to the specified precision
    final factor = pow(10, precision);
    return (value * factor).round() / factor;
  }

  // Swipe handling
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
      case SwipeDirection.up:
        // Up means normal
        return correctAnswer == ValueType.normal;
      case SwipeDirection.left:
        // Left means low
        return correctAnswer == ValueType.low;
      case SwipeDirection.right:
        // Right means high
        return correctAnswer == ValueType.high;
    }
  }

  void _handleCorrectAnswer() {
    // Increment streak
    final newStreak = state.currentStreak + 1;
    final newHighestStreak = max(newStreak, state.highestStreak);
    
    // Update stats in user profile
    final difficulty = _currentQuestion!.parameter.difficulty;
    final categoryId = _currentQuestion!.parameter.categoryID;
    
    // Update questions answered by difficulty
    final updatedQuestionsAnswered = Map<ParameterDifficulty, int>.from(
        _userProfile.questionsAnswered);
    updatedQuestionsAnswered[difficulty] = 
        (updatedQuestionsAnswered[difficulty] ?? 0) + 1;
    
    // Update category progress
    final updatedCategoryProgress = Map<String, int>.from(
        _userProfile.categoryProgress);
    updatedCategoryProgress[categoryId] = 
        (updatedCategoryProgress[categoryId] ?? 0) + 1;
    
    // Update user profile
    _userProfile = _userProfile.copyWith(
      highestStreak: newHighestStreak,
      currentStreak: newStreak,
      questionsAnswered: updatedQuestionsAnswered,
      categoryProgress: updatedCategoryProgress,
      lastPlayed: DateTime.now(),
    );
    
    // Update game state
    state = state.copyWith(
      currentStreak: newStreak,
      highestStreak: newHighestStreak,
      lastAnswerCorrect: true,
    );
    
    // Generate new question
    _generateNewQuestion();
  }

  void _handleWrongAnswer() {
    // Reset streak in user profile
    _userProfile = _userProfile.copyWith(
      currentStreak: 0,
      lastPlayed: DateTime.now(),
    );
    
    // Update game state
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
  final int currentStreak;
  final int highestStreak;
  final bool isActive;
  final bool? lastAnswerCorrect;
  final bool isPracticeMode;

  GameState({
    this.currentQuestion,
    this.currentStreak = 0,
    this.highestStreak = 0,
    this.isActive = false,
    this.lastAnswerCorrect,
    this.isPracticeMode = false,
  });

  GameState copyWith({
    GameQuestion? currentQuestion,
    int? currentStreak,
    int? highestStreak,
    bool? isActive,
    bool? lastAnswerCorrect,
    bool? isPracticeMode,
  }) {
    return GameState(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentStreak: currentStreak ?? this.currentStreak,
      highestStreak: highestStreak ?? this.highestStreak,
      isActive: isActive ?? this.isActive,
      lastAnswerCorrect: lastAnswerCorrect ?? this.lastAnswerCorrect,
      isPracticeMode: isPracticeMode ?? this.isPracticeMode,
    );
  }
}

// Use enums from medical_models.dart

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
