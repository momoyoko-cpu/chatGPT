import 'package:ai_poker_coach/shared/models/playing_card.dart';
import 'package:ai_poker_coach/shared/models/starting_hand.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayingCard', () {
    test('文字列表記と相互変換できる', () {
      final card = PlayingCard.parse('Ah');
      expect(card.rank, CardRank.ace);
      expect(card.suit, CardSuit.heart);
      expect(card.code, 'Ah');
      expect(card.display, 'A♥');
    });

    test('フルデッキは52枚で重複しない', () {
      final deck = PlayingCard.fullDeck;
      expect(deck, hasLength(52));
      expect(deck.toSet(), hasLength(52));
    });

    test('不正な表記は例外になる', () {
      expect(() => PlayingCard.parse('Ahh'), throwsFormatException);
    });
  });

  group('StartingHand', () {
    test('169種類がすべて一意に並ぶ', () {
      final hands = StartingHand.all;
      expect(hands, hasLength(169));
      expect(hands.map((hand) => hand.code).toSet(), hasLength(169));
    });

    test('グリッドの対角線はペア、右上はスーテッド、左下はオフスート', () {
      expect(StartingHand.fromGrid(0, 0).code, 'AA');
      expect(StartingHand.fromGrid(0, 1).code, 'AKs');
      expect(StartingHand.fromGrid(1, 0).code, 'AKo');
      expect(StartingHand.fromGrid(12, 12).code, '22');
    });

    test('実際の2枚から分類できる', () {
      expect(
        StartingHand.fromCards(
          PlayingCard.parse('Ah'),
          PlayingCard.parse('Kh'),
        ).code,
        'AKs',
      );
      expect(
        StartingHand.fromCards(
          PlayingCard.parse('Ah'),
          PlayingCard.parse('Kd'),
        ).code,
        'AKo',
      );
      expect(
        StartingHand.fromCards(
          PlayingCard.parse('7h'),
          PlayingCard.parse('7d'),
        ).code,
        '77',
      );
    });

    test('ランクの順序に関係なく同じハンドになる', () {
      expect(StartingHand.parse('KAs'), StartingHand.parse('AKs'));
    });
  });
}
