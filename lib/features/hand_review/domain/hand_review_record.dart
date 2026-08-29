import 'hand_review_input.dart';
import 'hand_review_result.dart';

/// 保存済みのハンドレビュー 1 件。Supabase の `hand_reviews` に対応する。
class HandReviewRecord {
  const HandReviewRecord({
    required this.id,
    required this.input,
    required this.result,
    required this.createdAt,
  });

  final String id;
  final HandReviewInput input;
  final HandReviewResult result;
  final DateTime createdAt;

  int get score => result.score;

  /// 履歴リストに出す 1 行の見出し。
  String get title {
    final hand = input.heroHand.map((card) => card.display).join(' ');
    return '${input.heroPosition.label} / $hand';
  }
}
