import 'table_type.dart';

/// ポジション。6MAX / 9MAX の両方を 1 つの enum で表現する。
enum Position {
  utg('UTG', 'アーリー'),
  utg1('UTG+1', 'アーリー'),
  mp('MP', 'ミドル'),
  lj('LJ', 'ミドル'),
  hj('HJ', 'レイト'),
  co('CO', 'レイト'),
  btn('BTN', 'レイト'),
  sb('SB', 'ブラインド'),
  bb('BB', 'ブラインド');

  const Position(this.label, this.groupLabel);

  /// UI 表示・AI 入力で使う短縮名。
  final String label;

  /// 「アーリー」「レイト」などのグループ名。初心者向けの補足に使う。
  final String groupLabel;

  static const List<Position> sixMaxOrder = [
    Position.utg,
    Position.hj,
    Position.co,
    Position.btn,
    Position.sb,
    Position.bb,
  ];

  static const List<Position> nineMaxOrder = [
    Position.utg,
    Position.utg1,
    Position.mp,
    Position.lj,
    Position.hj,
    Position.co,
    Position.btn,
    Position.sb,
    Position.bb,
  ];

  static List<Position> orderFor(TableType tableType) => switch (tableType) {
    TableType.sixMax => sixMaxOrder,
    TableType.nineMax => nineMaxOrder,
  };

  static Position fromLabel(String label) =>
      Position.values.firstWhere((position) => position.label == label);
}
