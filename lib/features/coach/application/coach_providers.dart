import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/application/learning_providers.dart';
import '../../quiz/application/quiz_providers.dart';
import '../domain/coach_message.dart';
import '../domain/coach_repository.dart';
import '../infrastructure/mock_coach_repository.dart';

final coachRepositoryProvider = Provider<CoachRepository>(
  (ref) => const MockCoachRepository(),
);

/// ホームに表示する今日のコーチコメント。
final coachBriefingProvider = Provider<CoachBriefing>((ref) {
  final session = ref.watch(dailyQuizSessionProvider);
  return ref
      .watch(coachRepositoryProvider)
      .briefing(
        displayName: ref.watch(userProfileProvider).displayName,
        stats: ref.watch(learningStatsProvider),
        todayAnswered: session.answeredCount,
        todayTotal: session.totalCount,
      );
});
