import 'quiz.dart';
import 'quiz_attempt.dart';

/// 「今日の10問」の進行状態。
class DailyQuizSession {
  const DailyQuizSession({
    required this.date,
    required this.quizzes,
    this.attempts = const {},
    this.currentIndex = 0,
    this.revealedChoiceId,
  });

  final DateTime date;
  final List<Quiz> quizzes;

  /// quizId -> 回答結果。
  final Map<String, QuizAttempt> attempts;

  /// 現在表示している問題の位置（0 始まり）。
  final int currentIndex;

  /// 回答済みで解説を表示中の選択肢 ID。未回答なら null。
  final String? revealedChoiceId;

  int get totalCount => quizzes.length;
  int get answeredCount => attempts.length;
  int get correctCount =>
      attempts.values.where((attempt) => attempt.isCorrect).length;

  bool get isFinished => answeredCount >= totalCount;
  bool get isAnswerRevealed => revealedChoiceId != null;

  /// 全問終わっているときは null。
  Quiz? get currentQuiz =>
      currentIndex < quizzes.length ? quizzes[currentIndex] : null;

  double get progress => totalCount == 0 ? 0 : answeredCount / totalCount;

  double get accuracy => answeredCount == 0 ? 0 : correctCount / answeredCount;

  DailyQuizSession copyWith({
    Map<String, QuizAttempt>? attempts,
    int? currentIndex,
    String? revealedChoiceId,
    bool clearRevealedChoice = false,
  }) {
    return DailyQuizSession(
      date: date,
      quizzes: quizzes,
      attempts: attempts ?? this.attempts,
      currentIndex: currentIndex ?? this.currentIndex,
      revealedChoiceId:
          clearRevealedChoice ? null : revealedChoiceId ?? this.revealedChoiceId,
    );
  }
}
