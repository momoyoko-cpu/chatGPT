import '../../../shared/models/playing_card.dart';
import '../../../shared/models/starting_hand.dart';

/// `22+, ATs+, KJo+, 76s` のようなレンジ表記を 169 ハンドへ展開する。
///
/// サポートする表記:
/// * `AA` `AKs` `AKo` … 単一ハンド
/// * `77+` … そのペア以上すべて
/// * `A5s+` … 同じハイカードで、キッカーがそのランク以上のスーテッド / オフスート
/// * `T9s-76s` … 同じギャップのコネクター帯
abstract final class RangeNotation {
  /// カンマ区切りのレンジ表記を展開する。
  static Set<String> expand(String notation) {
    final hands = <String>{};
    for (final rawToken in notation.split(',')) {
      final token = rawToken.trim();
      if (token.isEmpty) continue;
      hands.addAll(_expandToken(token));
    }
    return hands;
  }

  static Set<String> _expandToken(String token) {
    if (token.contains('-')) {
      return _expandDashRange(token);
    }
    if (token.endsWith('+')) {
      return _expandPlusRange(token.substring(0, token.length - 1));
    }
    return {StartingHand.parse(token).code};
  }

  static Set<String> _expandPlusRange(String base) {
    final hand = StartingHand.parse(base);
    final ranks = CardRank.descending;
    if (hand.isPair) {
      return {
        for (final rank in ranks)
          if (rank.strength >= hand.high.strength)
            StartingHand(rank, rank, HandShape.pair).code,
      };
    }
    // 例: A5s+ → A5s, A6s, ... AKs（ハイカードは固定、キッカーだけ上げる）
    return {
      for (final rank in ranks)
        if (rank.strength >= hand.low.strength &&
            rank.strength < hand.high.strength)
          StartingHand(hand.high, rank, hand.shape).code,
    };
  }

  static Set<String> _expandDashRange(String token) {
    final parts = token.split('-');
    if (parts.length != 2) {
      throw FormatException('レンジ表記が不正です: $token');
    }
    final from = StartingHand.parse(parts[0].trim());
    final to = StartingHand.parse(parts[1].trim());

    if (from.isPair && to.isPair) {
      final high = from.high.strength >= to.high.strength ? from.high : to.high;
      final low = from.high.strength >= to.high.strength ? to.high : from.high;
      return {
        for (final rank in CardRank.descending)
          if (rank.strength <= high.strength && rank.strength >= low.strength)
            StartingHand(rank, rank, HandShape.pair).code,
      };
    }

    if (from.shape != to.shape) {
      throw FormatException('スーテッド/オフスートが混在しています: $token');
    }

    final fromGap = from.high.strength - from.low.strength;
    final toGap = to.high.strength - to.low.strength;
    if (fromGap == toGap) {
      // 同じギャップの帯: T9s-76s → T9s, 98s, 87s, 76s
      final topHigh =
          from.high.strength >= to.high.strength ? from.high : to.high;
      final bottomHigh =
          from.high.strength >= to.high.strength ? to.high : from.high;
      return {
        for (final rank in CardRank.descending)
          if (rank.strength <= topHigh.strength &&
              rank.strength >= bottomHigh.strength)
            StartingHand(
              rank,
              CardRank.descending.firstWhere(
                (candidate) => candidate.strength == rank.strength - fromGap,
              ),
              from.shape,
            ).code,
      };
    }

    // ハイカード固定でキッカーを動かす帯: A5s-A2s
    if (from.high == to.high) {
      final top = from.low.strength >= to.low.strength ? from.low : to.low;
      final bottom = from.low.strength >= to.low.strength ? to.low : from.low;
      return {
        for (final rank in CardRank.descending)
          if (rank.strength <= top.strength && rank.strength >= bottom.strength)
            StartingHand(from.high, rank, from.shape).code,
      };
    }

    throw FormatException('対応していないレンジ表記です: $token');
  }
}
