import '../../../shared/models/starting_hand.dart';
import 'range_action.dart';
import 'range_spot.dart';

/// レンジ表の 1 ハンド分のデータ。Supabase の `range_actions` に対応する。
class RangeEntry {
  const RangeEntry({
    required this.hand,
    required this.action,
    required this.frequency,
  });

  final StartingHand hand;
  final RangeAction action;

  /// そのアクションを取る「目安の頻度」(0.0〜1.0)。
  ///
  /// ソルバーの厳密な出力ではなく、学習用の目安として扱う。
  final double frequency;
}

/// 1 つのスポットのレンジ表全体。
class RangeChart {
  const RangeChart({required this.spot, required this.entries});

  final RangeSpot spot;

  /// ハンド表記（`AKs` など）をキーにした 169 件のマップ。
  final Map<String, RangeEntry> entries;

  RangeEntry entryFor(StartingHand hand) =>
      entries[hand.code] ??
      RangeEntry(hand: hand, action: RangeAction.fold, frequency: 1);

  /// レンジに含まれるハンドの割合（Fold を除いた 169 分の割合）。
  ///
  /// 組み合わせ数で重み付けする（ペア6通り / スーテッド4通り / オフスート12通り）。
  double get vpipPercent {
    var played = 0.0;
    for (final hand in StartingHand.all) {
      final entry = entryFor(hand);
      if (entry.action == RangeAction.fold) continue;
      played += _combinations(hand) * entry.frequency;
    }
    return played / 1326 * 100;
  }

  static double _combinations(StartingHand hand) => switch (hand.shape) {
        HandShape.pair => 6,
        HandShape.suited => 4,
        HandShape.offsuit => 12,
      };
}
