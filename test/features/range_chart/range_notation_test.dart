import 'package:ai_poker_coach/features/range_chart/domain/range_notation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RangeNotation', () {
    test('単一ハンドを展開する', () {
      expect(RangeNotation.expand('AKs'), {'AKs'});
    });

    test('ペアの + はそれ以上すべてを含む', () {
      expect(
        RangeNotation.expand('TT+'),
        {'AA', 'KK', 'QQ', 'JJ', 'TT'},
      );
    });

    test('キッカーの + はハイカードを固定して広げる', () {
      expect(
        RangeNotation.expand('AJs+'),
        {'AKs', 'AQs', 'AJs'},
      );
      expect(RangeNotation.expand('KTo+'), {'KQo', 'KJo', 'KTo'});
    });

    test('同じギャップの帯を展開する', () {
      expect(
        RangeNotation.expand('T9s-76s'),
        {'T9s', '98s', '87s', '76s'},
      );
    });

    test('ハイカード固定の帯を展開する', () {
      expect(RangeNotation.expand('A5s-A2s'), {'A5s', 'A4s', 'A3s', 'A2s'});
    });

    test('ペアの帯を展開する', () {
      expect(RangeNotation.expand('22-55'), {'55', '44', '33', '22'});
    });

    test('カンマ区切りをまとめて展開する', () {
      expect(
        RangeNotation.expand('QQ+, AKs, 76s'),
        {'AA', 'KK', 'QQ', 'AKs', '76s'},
      );
    });

    test('空文字は空集合になる', () {
      expect(RangeNotation.expand(''), isEmpty);
    });

    test('不正な表記は例外になる', () {
      expect(() => RangeNotation.expand('AKs-72o'), throwsFormatException);
    });
  });
}
