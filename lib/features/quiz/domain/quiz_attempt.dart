import 'quiz_category.dart';

/// 1 問の回答結果。学習統計の元データになる。
class QuizAttempt {
  const QuizAttempt({
    required this.quizId,
    required this.category,
    required this.selectedChoiceId,
    required this.isCorrect,
    required this.answeredAt,
  });

  final String quizId;
  final QuizCategory category;
  final String selectedChoiceId;
  final bool isCorrect;
  final DateTime answeredAt;
}
