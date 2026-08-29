import '../../hand_review/domain/hand_review_record.dart';
import '../../quiz/domain/quiz_attempt.dart';

/// 学習履歴の生データ。
///
/// クイズ・ハンドレビュー・ホーム・コーチのすべてがここを参照する。
class LearningRecord {
  const LearningRecord({
    this.attempts = const [],
    this.reviews = const [],
    this.activeDays = const {},
  });

  final List<QuizAttempt> attempts;
  final List<HandReviewRecord> reviews;

  /// 学習した日（時刻なし）。連続学習日数の計算に使う。
  final Set<DateTime> activeDays;

  LearningRecord copyWith({
    List<QuizAttempt>? attempts,
    List<HandReviewRecord>? reviews,
    Set<DateTime>? activeDays,
  }) {
    return LearningRecord(
      attempts: attempts ?? this.attempts,
      reviews: reviews ?? this.reviews,
      activeDays: activeDays ?? this.activeDays,
    );
  }
}
