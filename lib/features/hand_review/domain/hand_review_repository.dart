import 'hand_review_input.dart';
import 'hand_review_result.dart';

/// ハンドレビュー AI の呼び出し口。
///
/// Phase 6 で Supabase Edge Function (`POST /review`) 経由の実装に差し替える。
/// OpenAI の API キーはアプリに埋め込まず、必ずサーバー側で保持する。
abstract interface class HandReviewRepository {
  Future<HandReviewResult> review(HandReviewInput input);
}
