/// AI コーチのメッセージ種別。Supabase の `coach_messages.message_type` に対応する。
enum CoachMessageType {
  daily('daily', '今日の一言'),
  focus('focus', '今日の重点テーマ'),
  growth('growth', '成長ポイント'),
  improvement('improvement', '改善ポイント'),
  tomorrow('tomorrow', '明日のおすすめ');

  const CoachMessageType(this.id, this.label);

  final String id;
  final String label;
}

/// AI コーチの 1 メッセージ。
class CoachMessage {
  const CoachMessage({
    required this.type,
    required this.message,
    required this.createdAt,
  });

  final CoachMessageType type;
  final String message;
  final DateTime createdAt;
}

/// ホームに出すコーチのまとめ。
class CoachBriefing {
  const CoachBriefing({required this.messages});

  final List<CoachMessage> messages;

  CoachMessage? of(CoachMessageType type) {
    for (final message in messages) {
      if (message.type == type) return message;
    }
    return null;
  }
}
