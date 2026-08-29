/// クイズのカテゴリ。学習統計と苦手分野の算出単位でもある。
enum QuizCategory {
  preflop('preflop', 'プリフロップ'),
  flop('flop', 'フロップ'),
  turn('turn', 'ターン'),
  river('river', 'リバー'),
  position('position', 'ポジション'),
  betSizing('bet_sizing', 'ベットサイズ'),
  potOdds('pot_odds', 'ポットオッズ'),
  valueBluff('value_bluff', 'バリュー / ブラフ'),
  gto('gto', 'GTO'),
  exploit('exploit', 'エクスプロイト');

  const QuizCategory(this.id, this.label);

  final String id;
  final String label;

  static QuizCategory fromId(String id) =>
      QuizCategory.values.firstWhere((category) => category.id == id);
}

/// 出題難易度。
enum QuizDifficulty {
  beginner(1, '初級'),
  intermediate(2, '中級'),
  advanced(3, '上級');

  const QuizDifficulty(this.level, this.label);

  final int level;
  final String label;
}
