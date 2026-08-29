/// ストリート。クイズのカテゴリとハンドレビューの分析単位に使う。
enum Street {
  preflop('preflop', 'プリフロップ'),
  flop('flop', 'フロップ'),
  turn('turn', 'ターン'),
  river('river', 'リバー');

  const Street(this.id, this.label);

  final String id;
  final String label;
}
