import '../../quiz/domain/quiz_attempt.dart';
import '../../quiz/domain/quiz_category.dart';

/// カテゴリ別の正誤集計。Supabase の `learning_stats` に対応する。
class CategoryStat {
  const CategoryStat({
    required this.category,
    required this.correctCount,
    required this.incorrectCount,
  });

  final QuizCategory category;
  final int correctCount;
  final int incorrectCount;

  int get total => correctCount + incorrectCount;
  double get accuracy => total == 0 ? 0 : correctCount / total;

  /// 苦手判定に足るだけの回答数があるか。
  bool get hasEnoughSamples => total >= 3;
}

/// 学習履歴から算出する集計値。
class LearningStats {
  const LearningStats({
    required this.attempts,
    required this.reviewCount,
    required this.streakDays,
    required this.activeDaysLast7,
    required this.activeDaysLast30,
  });

  final List<QuizAttempt> attempts;
  final int reviewCount;
  final int streakDays;
  final int activeDaysLast7;
  final int activeDaysLast30;

  int get totalAnswered => attempts.length;
  int get totalCorrect => attempts.where((attempt) => attempt.isCorrect).length;
  double get accuracy => totalAnswered == 0 ? 0 : totalCorrect / totalAnswered;

  /// カテゴリ別集計。回答のあるカテゴリのみ返す。
  List<CategoryStat> get categoryStats {
    final byCategory = <QuizCategory, List<QuizAttempt>>{};
    for (final attempt in attempts) {
      byCategory.putIfAbsent(attempt.category, () => []).add(attempt);
    }
    final stats = [
      for (final entry in byCategory.entries)
        CategoryStat(
          category: entry.key,
          correctCount: entry.value
              .where((attempt) => attempt.isCorrect)
              .length,
          incorrectCount: entry.value
              .where((attempt) => !attempt.isCorrect)
              .length,
        ),
    ];
    stats.sort((a, b) => a.accuracy.compareTo(b.accuracy));
    return stats;
  }

  /// 苦手分野。正答率が低く、かつ十分な回答数があるカテゴリ。
  List<QuizCategory> weakCategories({int limit = 3}) => [
    for (final stat in categoryStats)
      if (stat.hasEnoughSamples && stat.accuracy < 0.7) stat.category,
  ].take(limit).toList();

  /// 得意分野。
  List<QuizCategory> strongCategories({int limit = 3}) => [
    for (final stat in categoryStats.reversed)
      if (stat.hasEnoughSamples && stat.accuracy >= 0.8) stat.category,
  ].take(limit).toList();

  /// 直近 7 日の正答率。成長ポイントの算出に使う。
  double get accuracyLast7Days => _accuracySince(const Duration(days: 7));

  /// 8〜14 日前の正答率。直近との比較で「伸び」を出す。
  double get accuracyPreviousWeek {
    final now = DateTime.now();
    final from = now.subtract(const Duration(days: 14));
    final to = now.subtract(const Duration(days: 7));
    final window = attempts.where(
      (attempt) =>
          attempt.answeredAt.isAfter(from) && attempt.answeredAt.isBefore(to),
    );
    if (window.isEmpty) return 0;
    return window.where((attempt) => attempt.isCorrect).length / window.length;
  }

  double _accuracySince(Duration duration) {
    final from = DateTime.now().subtract(duration);
    final window = attempts.where(
      (attempt) => attempt.answeredAt.isAfter(from),
    );
    if (window.isEmpty) return 0;
    return window.where((attempt) => attempt.isCorrect).length / window.length;
  }

  /// 経験値からレベルを決める簡易ロジック。
  int get level => 1 + (totalCorrect ~/ 20) + (reviewCount ~/ 5);

  /// 次のレベルまでの進捗 (0.0〜1.0)。
  double get levelProgress {
    final points = totalCorrect + reviewCount * 4;
    return (points % 20) / 20;
  }
}
