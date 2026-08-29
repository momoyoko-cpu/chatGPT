import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_x.dart';
import '../../hand_review/domain/hand_review_record.dart';
import '../../quiz/domain/quiz_attempt.dart';
import '../domain/learning_record.dart';
import '../domain/learning_stats.dart';
import '../domain/user_profile.dart';
import '../infrastructure/mock_learning_seed.dart';

/// 学習履歴の唯一の保存場所。
///
/// Phase 3〜4 で Supabase の `quiz_attempts` / `hand_reviews` に置き換える。
/// その際もこの Notifier のインターフェースは変えずに済むようにしている。
class LearningStore extends Notifier<LearningRecord> {
  @override
  LearningRecord build() => MockLearningSeed.build();

  /// クイズの回答を記録する。同じ問題への再回答は上書きする。
  void recordAttempt(QuizAttempt attempt) {
    final attempts = [
      ...state.attempts.where(
        (existing) =>
            !(existing.quizId == attempt.quizId &&
                existing.answeredAt.isSameDay(attempt.answeredAt)),
      ),
      attempt,
    ];
    state = state.copyWith(
      attempts: attempts,
      activeDays: {...state.activeDays, attempt.answeredAt.dateOnly},
    );
  }

  /// ハンドレビューの結果を保存する。
  void recordReview(HandReviewRecord review) {
    state = state.copyWith(
      reviews: [review, ...state.reviews],
      activeDays: {...state.activeDays, review.createdAt.dateOnly},
    );
  }
}

final learningStoreProvider = NotifierProvider<LearningStore, LearningRecord>(
  LearningStore.new,
);

/// 学習履歴から算出した集計値。
final learningStatsProvider = Provider<LearningStats>((ref) {
  final record = ref.watch(learningStoreProvider);
  final now = DateTime.now();
  final last7 = now.subtract(const Duration(days: 7));
  final last30 = now.subtract(const Duration(days: 30));

  return LearningStats(
    attempts: record.attempts,
    reviewCount: record.reviews.length,
    streakDays: calculateStreak(record.activeDays),
    activeDaysLast7: record.activeDays
        .where((day) => day.isAfter(last7))
        .length,
    activeDaysLast30: record.activeDays
        .where((day) => day.isAfter(last30))
        .length,
  );
});

/// レビュー履歴（新しい順）。
final handReviewHistoryProvider = Provider<List<HandReviewRecord>>(
  (ref) => ref.watch(learningStoreProvider).reviews,
);

/// ログインユーザー。Phase 3 で Supabase Auth のユーザーに差し替える。
final userProfileProvider = Provider<UserProfile>(
  (ref) => UserProfile(
    id: 'local-user',
    displayName: 'プレイヤー',
    pokerLevel: PokerLevel.novice,
    createdAt: DateTime.now().subtract(const Duration(days: 24)),
  ),
);
