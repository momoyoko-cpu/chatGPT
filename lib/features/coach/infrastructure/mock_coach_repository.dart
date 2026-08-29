import '../../profile/domain/learning_stats.dart';
import '../domain/coach_message.dart';
import '../domain/coach_repository.dart';

/// 学習履歴からコーチのコメントを組み立てるローカル実装。
///
/// 事実に基づく文だけを組み立て、根拠のない数値は作らない。
class MockCoachRepository implements CoachRepository {
  const MockCoachRepository();

  @override
  CoachBriefing briefing({
    required String displayName,
    required LearningStats stats,
    required int todayAnswered,
    required int todayTotal,
  }) {
    final now = DateTime.now();
    final weak = stats.weakCategories();
    final strong = stats.strongCategories();

    final daily = switch (0) {
      _ when stats.totalAnswered == 0 =>
        'はじめまして、$displayName さん。まずは今日の10問から始めましょう。'
            '1日10問を1週間続けるだけで、判断の速さがはっきり変わります。',
      _ when todayAnswered >= todayTotal =>
        '今日の10問おつかれさまでした。正答率は ${(stats.accuracyLast7Days * 100).round()}%（直近7日）です。'
            '続けている人だけが伸びます。',
      _ when todayAnswered > 0 =>
        'あと ${todayTotal - todayAnswered} 問です。'
            '途中でやめず、最後まで解ききると記憶への残り方が変わります。',
      _ when stats.streakDays >= 3 =>
        '${stats.streakDays}日連続で学習できています。今日も10分だけ確保しましょう。',
      _ => '今日の10問がまだ残っています。10分で終わります。',
    };

    final focus = weak.isEmpty
        ? (stats.totalAnswered < 10
              ? 'まずは幅広いカテゴリを一巡しましょう。数問解くと、苦手分野が自動で見えてきます。'
              : '大きな苦手はまだ検出されていません。今日はレンジ表を1ポジション選んで、上下の境界を覚えましょう。')
        : '${weak.map((category) => category.label).join('・')} を重点的に練習しましょう。'
              'ここが安定すると、他の判断も一緒に楽になります。';

    final growth = switch (0) {
      _ when strong.isNotEmpty =>
        '${strong.map((category) => category.label).join('・')} はかなり安定しています。'
            'この分野は自信を持って判断して大丈夫です。',
      _
          when stats.accuracyLast7Days > stats.accuracyPreviousWeek &&
              stats.accuracyPreviousWeek > 0 =>
        '直近7日の正答率が、その前の週より '
            '${((stats.accuracyLast7Days - stats.accuracyPreviousWeek) * 100).round()} ポイント上がっています。',
      _ when stats.reviewCount > 0 =>
        'ハンドレビューを ${stats.reviewCount} 件記録できています。'
            '振り返りを残す習慣は、正答率より先に効いてきます。',
      _ => 'まだ比較できるデータが足りません。数日続けると、ここに成長の記録が出ます。',
    };

    final improvement = weak.isEmpty
        ? '苦手分野を出すには、各カテゴリ3問以上の回答が必要です。今日の10問を解き進めましょう。'
        : '${weak.first.label} の正答率が伸び悩んでいます。'
              '間違えた問題の「よくあるミス」を、答え合わせのときに必ず読んでください。';

    final tomorrow = weak.isEmpty
        ? '明日は今日と別のカテゴリに触れて、判断の幅を広げましょう。'
        : '明日も ${weak.first.label} から始めて、正答率が上がるか確認しましょう。'
              '同じテーマを2〜3日続けるのが一番効率的です。';

    return CoachBriefing(
      messages: [
        CoachMessage(
          type: CoachMessageType.daily,
          message: daily,
          createdAt: now,
        ),
        CoachMessage(
          type: CoachMessageType.focus,
          message: focus,
          createdAt: now,
        ),
        CoachMessage(
          type: CoachMessageType.growth,
          message: growth,
          createdAt: now,
        ),
        CoachMessage(
          type: CoachMessageType.improvement,
          message: improvement,
          createdAt: now,
        ),
        CoachMessage(
          type: CoachMessageType.tomorrow,
          message: tomorrow,
          createdAt: now,
        ),
      ],
    );
  }
}
