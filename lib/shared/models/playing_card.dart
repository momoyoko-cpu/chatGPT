/// カードのランク。`A` が最強で `2` が最弱。
enum CardRank {
  ace('A', 14),
  king('K', 13),
  queen('Q', 12),
  jack('J', 11),
  ten('T', 10),
  nine('9', 9),
  eight('8', 8),
  seven('7', 7),
  six('6', 6),
  five('5', 5),
  four('4', 4),
  three('3', 3),
  two('2', 2);

  const CardRank(this.symbol, this.strength);

  final String symbol;
  final int strength;

  static CardRank fromSymbol(String symbol) =>
      CardRank.values.firstWhere((rank) => rank.symbol == symbol.toUpperCase());

  /// レンジ表の 13x13 グリッドで使う、強い順のランク一覧。
  static List<CardRank> get descending => CardRank.values;
}

/// カードのスート。
enum CardSuit {
  spade('s', '♠'),
  heart('h', '♥'),
  diamond('d', '♦'),
  club('c', '♣');

  const CardSuit(this.code, this.symbol);

  final String code;
  final String symbol;

  bool get isRed => this == CardSuit.heart || this == CardSuit.diamond;

  static CardSuit fromCode(String code) =>
      CardSuit.values.firstWhere((suit) => suit.code == code.toLowerCase());
}

/// 1 枚のトランプ。`Ah` のような文字列表現と相互変換できる。
class PlayingCard {
  const PlayingCard(this.rank, this.suit);

  final CardRank rank;
  final CardSuit suit;

  /// `Ah` `Ts` のような表記からカードを生成する。
  factory PlayingCard.parse(String code) {
    if (code.length != 2) {
      throw FormatException('カード表記は2文字である必要があります: $code');
    }
    return PlayingCard(
      CardRank.fromSymbol(code[0]),
      CardSuit.fromCode(code[1]),
    );
  }

  /// `Ah` のような表記。AI へ渡す JSON でも同じ形式を使う。
  String get code => '${rank.symbol}${suit.code}';

  /// 画面表示用の `A♥` 形式。
  String get display => '${rank.symbol}${suit.symbol}';

  static List<PlayingCard> parseAll(Iterable<String> codes) =>
      codes.map(PlayingCard.parse).toList(growable: false);

  static List<String> encodeAll(Iterable<PlayingCard> cards) =>
      cards.map((card) => card.code).toList(growable: false);

  /// 52 枚のフルデッキ。カードピッカーで使う。
  static List<PlayingCard> get fullDeck => [
        for (final suit in CardSuit.values)
          for (final rank in CardRank.values) PlayingCard(rank, suit),
      ];

  @override
  bool operator ==(Object other) =>
      other is PlayingCard && other.rank == rank && other.suit == suit;

  @override
  int get hashCode => Object.hash(rank, suit);

  @override
  String toString() => code;
}
