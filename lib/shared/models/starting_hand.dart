import 'playing_card.dart';

/// スターティングハンドの種類。
enum HandShape {
  pair('', 'ペア'),
  suited('s', 'スーテッド'),
  offsuit('o', 'オフスート');

  const HandShape(this.suffix, this.label);

  final String suffix;
  final String label;
}

/// `AKs` `77` `QJo` のような 169 種類のスターティングハンド。
///
/// レンジ表の 1 マスに対応する。
class StartingHand {
  StartingHand(CardRank first, CardRank second, this.shape)
      : high = first.strength >= second.strength ? first : second,
        low = first.strength >= second.strength ? second : first {
    if (high == low && shape != HandShape.pair) {
      throw ArgumentError('同じランクの組み合わせはペアである必要があります');
    }
    if (high != low && shape == HandShape.pair) {
      throw ArgumentError('異なるランクの組み合わせはペアにできません');
    }
  }

  final CardRank high;
  final CardRank low;
  final HandShape shape;

  /// `AKs` のような表記。
  String get code => '${high.symbol}${low.symbol}${shape.suffix}';

  /// `A♥K♥` のような具体的なカードではなく、ハンドの説明文。
  String get description => high == low
      ? 'ポケット${high.symbol}${low.symbol}'
      : '${high.symbol}${low.symbol}の${shape.label}';

  bool get isPair => shape == HandShape.pair;

  /// `AKs` のような文字列からハンドを生成する。
  factory StartingHand.parse(String code) {
    if (code.length < 2 || code.length > 3) {
      throw FormatException('ハンド表記が不正です: $code');
    }
    final first = CardRank.fromSymbol(code[0]);
    final second = CardRank.fromSymbol(code[1]);
    if (first == second) {
      return StartingHand(first, second, HandShape.pair);
    }
    if (code.length != 3) {
      throw FormatException('スーテッド/オフスートの指定が必要です: $code');
    }
    final shape =
        code[2].toLowerCase() == 's' ? HandShape.suited : HandShape.offsuit;
    return StartingHand(first, second, shape);
  }

  /// 実際の 2 枚のカードから、対応する 169 分類のハンドを求める。
  factory StartingHand.fromCards(PlayingCard a, PlayingCard b) {
    if (a.rank == b.rank) {
      return StartingHand(a.rank, b.rank, HandShape.pair);
    }
    return StartingHand(
      a.rank,
      b.rank,
      a.suit == b.suit ? HandShape.suited : HandShape.offsuit,
    );
  }

  /// レンジ表グリッドの (row, column) に対応するハンド。
  ///
  /// 対角線がペア、右上がスーテッド、左下がオフスート、という標準的な並び。
  factory StartingHand.fromGrid(int row, int column) {
    final ranks = CardRank.descending;
    final rowRank = ranks[row];
    final columnRank = ranks[column];
    if (row == column) {
      return StartingHand(rowRank, columnRank, HandShape.pair);
    }
    return StartingHand(
      rowRank,
      columnRank,
      row < column ? HandShape.suited : HandShape.offsuit,
    );
  }

  /// 169 種類すべて。
  static List<StartingHand> get all => [
        for (var row = 0; row < CardRank.values.length; row++)
          for (var column = 0; column < CardRank.values.length; column++)
            StartingHand.fromGrid(row, column),
      ];

  @override
  bool operator ==(Object other) =>
      other is StartingHand &&
      other.high == high &&
      other.low == low &&
      other.shape == shape;

  @override
  int get hashCode => Object.hash(high, low, shape);

  @override
  String toString() => code;
}
