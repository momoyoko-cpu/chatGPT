import '../../../shared/models/playing_card.dart';
import '../../../shared/models/poker_action.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/table_type.dart';

/// キャッシュ / トーナメントの別。
enum GameType {
  cash('cash', 'Cash'),
  tournament('tournament', 'Tournament');

  const GameType(this.id, this.label);

  final String id;
  final String label;
}

/// 相手の傾向。実戦調整の解説を切り替えるために使う。
enum VillainProfile {
  unknown('unknown', 'Unknown'),
  tight('tight', 'Tight'),
  loose('loose', 'Loose'),
  passive('passive', 'Passive'),
  aggressive('aggressive', 'Aggressive');

  const VillainProfile(this.id, this.label);

  final String id;
  final String label;
}

/// プレイ環境。
enum PlayEnvironment {
  online('online', 'Online'),
  live('live', 'Live');

  const PlayEnvironment(this.id, this.label);

  final String id;
  final String label;
}

/// ポストフロップ 1 ストリート分の入力。
class StreetInput {
  const StreetInput({this.cards = const [], this.actions = const []});

  final List<PlayingCard> cards;
  final List<HandAction> actions;

  bool get isEmpty => cards.isEmpty && actions.isEmpty;

  StreetInput copyWith({List<PlayingCard>? cards, List<HandAction>? actions}) =>
      StreetInput(cards: cards ?? this.cards, actions: actions ?? this.actions);
}

/// ハンドレビューの入力。仕様書 5-2 の JSON と 1 対 1 で対応する。
class HandReviewInput {
  const HandReviewInput({
    this.gameType = GameType.cash,
    this.tableType = TableType.sixMax,
    this.smallBlind = 0.5,
    this.bigBlind = 1,
    this.effectiveStackBb = 100,
    this.heroPosition = Position.btn,
    this.heroHand = const [],
    this.villainPosition = Position.bb,
    this.villainProfile = VillainProfile.unknown,
    this.environment = PlayEnvironment.online,
    this.preflop = const [],
    this.flop = const StreetInput(),
    this.turn = const StreetInput(),
    this.river = const StreetInput(),
    this.userQuestion = '',
  });

  final GameType gameType;
  final TableType tableType;
  final double smallBlind;
  final double bigBlind;
  final double effectiveStackBb;
  final Position heroPosition;
  final List<PlayingCard> heroHand;
  final Position villainPosition;
  final VillainProfile villainProfile;
  final PlayEnvironment environment;
  final List<HandAction> preflop;
  final StreetInput flop;
  final StreetInput turn;
  final StreetInput river;

  /// 「自分が迷ったポイント」。任意入力。
  final String userQuestion;

  /// AI へ送れる最低限の入力が揃っているか。
  bool get isSubmittable => heroHand.length == 2 && preflop.isNotEmpty;

  /// フロップ以降のボード全体。
  List<PlayingCard> get board => [...flop.cards, ...turn.cards, ...river.cards];

  /// 到達した最終ストリートの名前。
  String get lastStreetLabel {
    if (river.cards.isNotEmpty) return 'リバー';
    if (turn.cards.isNotEmpty) return 'ターン';
    if (flop.cards.isNotEmpty) return 'フロップ';
    return 'プリフロップ';
  }

  HandReviewInput copyWith({
    GameType? gameType,
    TableType? tableType,
    double? smallBlind,
    double? bigBlind,
    double? effectiveStackBb,
    Position? heroPosition,
    List<PlayingCard>? heroHand,
    Position? villainPosition,
    VillainProfile? villainProfile,
    PlayEnvironment? environment,
    List<HandAction>? preflop,
    StreetInput? flop,
    StreetInput? turn,
    StreetInput? river,
    String? userQuestion,
  }) {
    return HandReviewInput(
      gameType: gameType ?? this.gameType,
      tableType: tableType ?? this.tableType,
      smallBlind: smallBlind ?? this.smallBlind,
      bigBlind: bigBlind ?? this.bigBlind,
      effectiveStackBb: effectiveStackBb ?? this.effectiveStackBb,
      heroPosition: heroPosition ?? this.heroPosition,
      heroHand: heroHand ?? this.heroHand,
      villainPosition: villainPosition ?? this.villainPosition,
      villainProfile: villainProfile ?? this.villainProfile,
      environment: environment ?? this.environment,
      preflop: preflop ?? this.preflop,
      flop: flop ?? this.flop,
      turn: turn ?? this.turn,
      river: river ?? this.river,
      userQuestion: userQuestion ?? this.userQuestion,
    );
  }

  /// Edge Function `POST /review` へ送る JSON。仕様書 5-2 の形式。
  Map<String, dynamic> toJson() => {
    'game_type': gameType.id,
    'table_type': tableType.id,
    'small_blind': smallBlind,
    'big_blind': bigBlind,
    'effective_stack_bb': effectiveStackBb,
    'hero_position': heroPosition.label,
    'hero_hand': PlayingCard.encodeAll(heroHand),
    'villain_position': villainPosition.label,
    'villain_profile': villainProfile.id,
    'environment': environment.id,
    'preflop': [for (final action in preflop) action.toJson()],
    'flop': {
      'board': PlayingCard.encodeAll(flop.cards),
      'actions': [for (final action in flop.actions) action.toJson()],
    },
    'turn': {
      'card': turn.cards.isEmpty ? null : turn.cards.first.code,
      'actions': [for (final action in turn.actions) action.toJson()],
    },
    'river': {
      'card': river.cards.isEmpty ? null : river.cards.first.code,
      'actions': [for (final action in river.actions) action.toJson()],
    },
    'user_question': userQuestion,
  };
}
