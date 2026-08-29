import '../../profile/domain/learning_stats.dart';
import 'coach_message.dart';

/// AI コーチの生成口。
///
/// Phase 7 で Edge Function (`GET /coach/today`) 経由の実装に差し替える。
abstract interface class CoachRepository {
  CoachBriefing briefing({
    required String displayName,
    required LearningStats stats,
    required int todayAnswered,
    required int todayTotal,
  });
}
