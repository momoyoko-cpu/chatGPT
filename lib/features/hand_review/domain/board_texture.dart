import '../../../shared/models/playing_card.dart';

/// ボードの質感。ベットサイズの妥当性を判断するために使う。
enum BoardWetness {
  dry('ドライ（当たりにくい）'),
  neutral('ややドロー含み'),
  wet('ウェット（ドローが多い）');

  const BoardWetness(this.label);

  final String label;
}

/// フロップ 3 枚のボードを、初心者にも説明できる粒度で分類する。
class BoardTexture {
  const BoardTexture({
    required this.wetness,
    required this.hasFlushDraw,
    required this.isMonotone,
    required this.isPaired,
    required this.hasStraightDraw,
    required this.highCardStrength,
  });

  final BoardWetness wetness;
  final bool hasFlushDraw;
  final bool isMonotone;
  final bool isPaired;
  final bool hasStraightDraw;
  final int highCardStrength;

  bool get isHighCardBoard => highCardStrength >= 12;

  /// 3 枚以上のボードから質感を求める。3 枚未満なら null。
  static BoardTexture? of(List<PlayingCard> board) {
    if (board.length < 3) return null;
    final flop = board.take(3).toList();

    final suitCounts = <CardSuit, int>{};
    for (final card in flop) {
      suitCounts.update(card.suit, (count) => count + 1, ifAbsent: () => 1);
    }
    final maxSuit = suitCounts.values.reduce((a, b) => a > b ? a : b);

    final strengths = flop.map((card) => card.rank.strength).toList()..sort();
    final isPaired = strengths.toSet().length < flop.length;
    final span = strengths.last - strengths.first;
    final hasStraightDraw = !isPaired && span <= 4;

    final hasFlushDraw = maxSuit >= 2;
    final isMonotone = maxSuit >= 3;

    final wetness = switch (0) {
      _ when isMonotone || (maxSuit == 2 && hasStraightDraw) =>
        BoardWetness.wet,
      _ when hasStraightDraw || maxSuit == 2 => BoardWetness.neutral,
      _ => BoardWetness.dry,
    };

    return BoardTexture(
      wetness: wetness,
      hasFlushDraw: hasFlushDraw,
      isMonotone: isMonotone,
      isPaired: isPaired,
      hasStraightDraw: hasStraightDraw,
      highCardStrength: strengths.last,
    );
  }
}
