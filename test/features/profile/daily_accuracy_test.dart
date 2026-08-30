import 'package:ai_poker_coach/features/profile/domain/learning_stats.dart';
import 'package:ai_poker_coach/features/quiz/domain/quiz_attempt.dart';
import 'package:ai_poker_coach/features/quiz/domain/quiz_category.dart';
import 'package:flutter_test/flutter_test.dart';

QuizAttempt _attempt({required bool isCorrect, required DateTime answeredAt}) {
  return QuizAttempt(
    quizId: 'q-${answeredAt.day}-$isCorrect',
    category: QuizCategory.preflop,
    selectedChoiceId: 'c0',
    isCorrect: isCorrect,
    answeredAt: answeredAt,
  );
}

void main() {
  final today = DateTime(2026, 8, 29, 20);

  LearningStats statsWith(List<QuizAttempt> attempts) => LearningStats(
    attempts: attempts,
    reviewCount: 0,
    streakDays: 1,
    activeDaysLast7: 1,
    activeDaysLast30: 1,
  );

  group('LearningStats.dailyAccuracy', () {
    test('日ごとにまとめ、古い順に並ぶ', () {
      final stats = statsWith([
        _attempt(isCorrect: true, answeredAt: today),
        _attempt(
          isCorrect: false,
          answeredAt: today.add(const Duration(minutes: 5)),
        ),
        _attempt(
          isCorrect: true,
          answeredAt: today.subtract(const Duration(days: 2)),
        ),
      ]);

      final series = stats.dailyAccuracy(today: today);
      expect(series, hasLength(2));
      expect(series.first.day.day, 27);
      expect(series.first.accuracy, 1.0);
      expect(series.last.day.day, 29);
      expect(series.last.accuracy, 0.5);
      expect(series.last.answered, 2);
    });

    test('指定日数より古い回答は含めない', () {
      final stats = statsWith([
        _attempt(
          isCorrect: true,
          answeredAt: today.subtract(const Duration(days: 20)),
        ),
        _attempt(isCorrect: true, answeredAt: today),
      ]);

      expect(stats.dailyAccuracy(days: 14, today: today), hasLength(1));
    });

    test('回答が無ければ空になる', () {
      expect(statsWith(const []).dailyAccuracy(today: today), isEmpty);
    });
  });

  test('カテゴリには軸ラベル用の短縮名がある', () {
    for (final category in QuizCategory.values) {
      expect(category.shortLabel, isNotEmpty, reason: category.id);
      expect(category.shortLabel.length, lessThanOrEqualTo(4));
    }
  });
}
