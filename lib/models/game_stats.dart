import '../models/medical_models.dart';

// Game statistics tracking
class GameStats {
  final int totalQuestions;  // Renamed from totalQuestionsAnswered for compatibility
  final int correctAnswers;
  final int wrongAnswers;
  final int currentStreak;
  final int bestStreak;
  final Map<String, int> categoryAnswers;
  final Map<ParameterDifficulty, int> answeredByDifficulty;
  final Map<ParameterDifficulty, int> correctByDifficulty;
  final DateTime? lastPlayed;

  GameStats({
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    Map<String, int>? categoryAnswers,
    Map<ParameterDifficulty, int>? answeredByDifficulty,
    Map<ParameterDifficulty, int>? correctByDifficulty,
    this.lastPlayed,
  }) : 
    categoryAnswers = categoryAnswers ?? {},
    answeredByDifficulty = answeredByDifficulty ?? {},
    correctByDifficulty = correctByDifficulty ?? {};

  GameStats copyWith({
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? currentStreak,
    int? bestStreak,
    Map<String, int>? categoryAnswers,
    Map<ParameterDifficulty, int>? answeredByDifficulty,
    Map<ParameterDifficulty, int>? correctByDifficulty,
    DateTime? lastPlayed,
  }) {
    return GameStats(
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      categoryAnswers: categoryAnswers ?? this.categoryAnswers,
      answeredByDifficulty: answeredByDifficulty ?? this.answeredByDifficulty,
      correctByDifficulty: correctByDifficulty ?? this.correctByDifficulty,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  // Calculate accuracy percentage
  double get accuracy => 
      totalQuestions > 0 
          ? (correctAnswers / totalQuestions) 
          : 0.0;
          
  // Get accuracy by difficulty level
  Map<ParameterDifficulty, double> get accuracyByDifficulty {
    final result = <ParameterDifficulty, double>{};
    for (final difficulty in ParameterDifficulty.values) {
      final answered = answeredByDifficulty[difficulty] ?? 0;
      final correct = correctByDifficulty[difficulty] ?? 0;
      result[difficulty] = answered > 0 ? correct / answered : 0.0;
    }
    return result;
  }
}
