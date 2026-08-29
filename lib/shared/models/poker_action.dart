/// プレイヤーが選択できるアクション。クイズの選択肢とハンドレビュー入力で共有する。
enum PokerActionType {
  fold('Fold', 'フォールド'),
  check('Check', 'チェック'),
  call('Call', 'コール'),
  limp('Limp', 'リンプ'),
  bet33('Bet 33%', 'ポットの33%ベット'),
  bet50('Bet 50%', 'ポットの50%ベット'),
  bet75('Bet 75%', 'ポットの75%ベット'),
  betPot('Bet Pot', 'ポットサイズベット'),
  raise('Raise', 'レイズ'),
  threeBet('3Bet', 'スリーベット'),
  fourBet('4Bet', 'フォーベット'),
  allIn('All-in', 'オールイン');

  const PokerActionType(this.label, this.description);

  final String label;
  final String description;

  /// プリフロップのハンドレビュー入力で並べるアクション。
  static const List<PokerActionType> preflopChoices = [
    PokerActionType.fold,
    PokerActionType.limp,
    PokerActionType.call,
    PokerActionType.raise,
    PokerActionType.threeBet,
    PokerActionType.fourBet,
    PokerActionType.allIn,
  ];

  /// ポストフロップのハンドレビュー入力で並べるアクション。
  static const List<PokerActionType> postflopChoices = [
    PokerActionType.fold,
    PokerActionType.check,
    PokerActionType.call,
    PokerActionType.bet33,
    PokerActionType.bet50,
    PokerActionType.bet75,
    PokerActionType.betPot,
    PokerActionType.raise,
    PokerActionType.allIn,
  ];
}

/// 「誰が何をしたか」を表す 1 アクション。
class HandAction {
  const HandAction({required this.actor, required this.action, this.sizeBb});

  /// `hero` もしくはポジション名（`BB` など）。
  final String actor;
  final PokerActionType action;

  /// 任意。BB 単位のベット額。
  final double? sizeBb;

  bool get isHero => actor == heroActor;

  /// 画面表示用のアクター名。JSON では `hero` のまま送る。
  String get actorLabel => isHero ? 'あなた' : actor;

  static const String heroActor = 'hero';

  Map<String, dynamic> toJson() => {
    'actor': actor,
    'action': action.label,
    if (sizeBb != null) 'size_bb': sizeBb,
  };

  @override
  String toString() => sizeBb == null
      ? '$actorLabel ${action.label}'
      : '$actorLabel ${action.label} (${sizeBb}BB)';
}
