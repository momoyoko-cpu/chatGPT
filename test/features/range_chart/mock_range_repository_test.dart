import 'package:ai_poker_coach/features/range_chart/domain/range_action.dart';
import 'package:ai_poker_coach/features/range_chart/domain/range_guidance.dart';
import 'package:ai_poker_coach/features/range_chart/infrastructure/mock_range_repository.dart';
import 'package:ai_poker_coach/shared/models/position.dart';
import 'package:ai_poker_coach/shared/models/starting_hand.dart';
import 'package:ai_poker_coach/shared/models/table_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const repository = MockRangeRepository();

  test('すべてのレンジ表が169ハンドを持つ', () {
    for (final tableType in TableType.values) {
      for (final position in Position.orderFor(tableType)) {
        final chart = repository.chartFor(tableType, position);
        expect(
          chart,
          isNotNull,
          reason: '${tableType.label} ${position.label}',
        );
        expect(chart!.entries, hasLength(169));
      }
    }
  });

  test('AA はどのポジションでも降りない', () {
    for (final tableType in TableType.values) {
      for (final position in Position.orderFor(tableType)) {
        final chart = repository.chartFor(tableType, position)!;
        expect(
          chart.entryFor(StartingHand.parse('AA')).action,
          isNot(RangeAction.fold),
          reason: '${tableType.label} ${position.label}',
        );
      }
    }
  });

  test('72o は UTG のオープンレンジに入らない', () {
    final chart = repository.chartFor(TableType.sixMax, Position.utg)!;
    expect(chart.entryFor(StartingHand.parse('72o')).action, RangeAction.fold);
  });

  test('レンジはポジションが後ろになるほど広がる', () {
    final utg = repository.chartFor(TableType.sixMax, Position.utg)!;
    final co = repository.chartFor(TableType.sixMax, Position.co)!;
    final btn = repository.chartFor(TableType.sixMax, Position.btn)!;

    expect(utg.vpipPercent, lessThan(co.vpipPercent));
    expect(co.vpipPercent, lessThan(btn.vpipPercent));
    expect(btn.vpipPercent, greaterThan(35));
    expect(utg.vpipPercent, lessThan(25));
  });

  test('9MAX の UTG は 6MAX の UTG より狭い', () {
    final sixMax = repository.chartFor(TableType.sixMax, Position.utg)!;
    final nineMax = repository.chartFor(TableType.nineMax, Position.utg)!;
    expect(nineMax.vpipPercent, lessThan(sixMax.vpipPercent));
  });

  test('BB はディフェンス表になり 3Bet と Call を含む', () {
    final chart = repository.chartFor(TableType.sixMax, Position.bb)!;
    final actions = chart.entries.values.map((entry) => entry.action).toSet();
    expect(actions, contains(RangeAction.threeBet));
    expect(actions, contains(RangeAction.call));
  });

  test('スポット ID から取得できる', () {
    final chart = repository.chartById('6max_btn_open');
    expect(chart, isNotNull);
    expect(chart!.spot.heroPosition, Position.btn);
    expect(repository.chartById('unknown_spot'), isNull);
  });

  test('解説はハンドごとに4つの観点を返す', () {
    final chart = repository.chartFor(TableType.sixMax, Position.btn)!;
    final guidance = RangeGuidanceBuilder.build(
      spot: chart.spot,
      entry: chart.entryFor(StartingHand.parse('AKs')),
    );
    expect(guidance.reason, isNotEmpty);
    expect(guidance.beginnerNote, isNotEmpty);
    expect(guidance.gtoNote, isNotEmpty);
    expect(guidance.practicalNote, isNotEmpty);
    expect(guidance.frequencyLabel, contains('Raise'));
  });
}
