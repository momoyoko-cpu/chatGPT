import '../../../shared/models/position.dart';
import '../../../shared/models/table_type.dart';

/// レンジ表のシチュエーション。
enum RangeSituation {
  openRaise('open_raise', 'Open Raise'),
  vsOpen('vs_open', 'vs Open'),
  vsThreeBet('vs_3bet', 'vs 3Bet'),
  vsFourBet('vs_4bet', 'vs 4Bet');

  const RangeSituation(this.id, this.label);

  final String id;
  final String label;
}

/// 1 つのレンジ表のメタ情報。Supabase の `range_spots` に対応する。
class RangeSpot {
  const RangeSpot({
    required this.id,
    required this.tableType,
    required this.situation,
    required this.heroPosition,
    required this.stackBb,
    required this.title,
    this.villainPosition,
    required this.headline,
  });

  final String id;
  final TableType tableType;
  final RangeSituation situation;
  final Position heroPosition;
  final Position? villainPosition;
  final double stackBb;
  final String title;

  /// 表の上部に出す 1 行サマリー。
  final String headline;
}
