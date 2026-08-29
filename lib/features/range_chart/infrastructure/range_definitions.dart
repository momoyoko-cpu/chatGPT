import '../../../shared/models/position.dart';
import '../../../shared/models/table_type.dart';
import '../domain/range_action.dart';
import '../domain/range_spot.dart';

/// 1 つのスポットのレンジ定義。
///
/// ハンドはレンジ表記（`22+, ATs+` など）で保持し、表示時に 169 ハンドへ展開する。
class RangeDefinition {
  const RangeDefinition({
    required this.spot,
    required this.notationByAction,
    this.mixedNotation = '',
  });

  final RangeSpot spot;

  /// アクションごとのレンジ表記。後ろのアクションが前を上書きする。
  final Map<RangeAction, String> notationByAction;

  /// 境界線上のハンド。最後に適用される。
  final String mixedNotation;
}

/// MVP で同梱するレンジ定義。
///
/// 数値はソルバー出力そのものではなく、初心者が覚えやすいように整理した学習用の目安。
abstract final class RangeDefinitions {
  static const double _defaultStackBb = 100;

  static List<RangeDefinition> get all => [
        ..._sixMax,
        ..._nineMax,
      ];

  static RangeDefinition? find(TableType tableType, Position position) {
    for (final definition in all) {
      if (definition.spot.tableType == tableType &&
          definition.spot.heroPosition == position) {
        return definition;
      }
    }
    return null;
  }

  static RangeDefinition _openRaise({
    required TableType tableType,
    required Position position,
    required String raise,
    String mixed = '',
    required String headline,
  }) {
    return RangeDefinition(
      spot: RangeSpot(
        id: '${tableType.id}_${position.label.toLowerCase()}_open',
        tableType: tableType,
        situation: RangeSituation.openRaise,
        heroPosition: position,
        stackBb: _defaultStackBb,
        title: '${tableType.label} / ${position.label} オープンレイズ',
        headline: headline,
      ),
      notationByAction: {RangeAction.raise: raise},
      mixedNotation: mixed,
    );
  }

  static RangeDefinition _bbDefense(TableType tableType) {
    return RangeDefinition(
      spot: RangeSpot(
        id: '${tableType.id}_bb_defense',
        tableType: tableType,
        situation: RangeSituation.vsOpen,
        heroPosition: Position.bb,
        villainPosition: Position.btn,
        stackBb: _defaultStackBb,
        title: '${tableType.label} / BB ディフェンス vs BTN オープン',
        headline: 'BB は自分からオープンできないポジション。BTN の 2.5BB オープンに対する守り方を確認しましょう。',
      ),
      notationByAction: {
        RangeAction.threeBet:
            '99+, AJs+, KQs, A5s-A4s, AQo+',
        RangeAction.call:
            '22-88, A2s+, K2s+, Q5s+, J7s+, T7s+, 96s+, 85s+, 75s+, 64s+, 53s+, '
            'A2o+, K8o+, Q9o+, J9o+, T9o, 98o',
      },
      mixedNotation: 'K7o, Q8o, J8o, T8o, 87o, 76o',
    );
  }

  // ---------------------------------------------------------------- 6MAX ----

  static final List<RangeDefinition> _sixMax = [
    _openRaise(
      tableType: TableType.sixMax,
      position: Position.utg,
      headline: '後ろに 5 人残っている一番不利な席。強いハンドに絞ります。',
      raise: '55+, A9s+, KTs+, QTs+, J9s+, T9s, 98s, AJo+, KQo',
      mixed: '44, A8s, K9s, 87s, ATo',
    ),
    _openRaise(
      tableType: TableType.sixMax,
      position: Position.hj,
      headline: 'UTG より少しだけ広げられます。まだ後ろに 4 人います。',
      raise: '44+, A7s+, A5s-A4s, K9s+, Q9s+, J9s+, T8s+, 97s+, 87s, ATo+, KJo+',
      mixed: '33, A6s, K8s, Q8s, 76s, KTo, QJo',
    ),
    _openRaise(
      tableType: TableType.sixMax,
      position: Position.co,
      headline: '後ろは BTN とブラインドだけ。ここからレンジを大きく広げます。',
      raise:
          '22+, A2s+, K7s+, Q8s+, J8s+, T8s+, 97s+, 86s+, 76s, 65s, A9o+, KTo+, QTo+, JTo',
      mixed: 'K6s, Q7s, J7s, T7s, 54s, A8o, K9o, Q9o',
    ),
    _openRaise(
      tableType: TableType.sixMax,
      position: Position.btn,
      headline: '最も有利な席。ポストフロップで常に最後に動けるので、かなり広く戦えます。',
      raise:
          '22+, A2s+, K2s+, Q4s+, J6s+, T6s+, 95s+, 85s+, 74s+, 64s+, 53s+, '
          'A2o+, K7o+, Q8o+, J8o+, T8o+, 98o, 87o, 76o',
      mixed: 'Q3s, J5s, T5s, 94s, 84s, 63s, 43s, K6o, Q7o, J7o, 65o',
    ),
    _openRaise(
      tableType: TableType.sixMax,
      position: Position.sb,
      headline: 'BB とのヘッズアップ。広く入れますが、ポストフロップは常に不利です。',
      raise:
          '22+, A2s+, K5s+, Q6s+, J7s+, T7s+, 96s+, 86s+, 75s+, 65s, 54s, '
          'A4o+, K9o+, Q9o+, J9o+, T9o',
      mixed: 'K4s, Q5s, J6s, T6s, A2o, A3o, K8o, Q8o, J8o',
    ),
    _bbDefense(TableType.sixMax),
  ];

  // ---------------------------------------------------------------- 9MAX ----

  static final List<RangeDefinition> _nineMax = [
    _openRaise(
      tableType: TableType.nineMax,
      position: Position.utg,
      headline: '9人テーブルで最も不利な席。ほぼプレミアムハンドだけで戦います。',
      raise: '77+, ATs+, KJs+, QJs, JTs, AQo+',
      mixed: '66, A9s, KTs, T9s, AJo, KQo',
    ),
    _openRaise(
      tableType: TableType.nineMax,
      position: Position.utg1,
      headline: 'UTG とほぼ同じ考え方。まだ 7 人が後ろにいます。',
      raise: '66+, A9s+, KTs+, QTs+, JTs, T9s, AJo+, KQo',
      mixed: '55, A8s, K9s, 98s, ATo, KJo',
    ),
    _openRaise(
      tableType: TableType.nineMax,
      position: Position.mp,
      headline: '少しだけ広げられますが、まだアーリー寄りの席です。',
      raise: '55+, A8s+, KTs+, Q9s+, J9s+, T9s, 98s, AJo+, KQo',
      mixed: '44, A7s, A5s, K9s, 87s, ATo, KJo',
    ),
    _openRaise(
      tableType: TableType.nineMax,
      position: Position.lj,
      headline: 'ここからミドル〜レイト。スーテッドハンドを足していきます。',
      raise: '44+, A7s+, A5s-A4s, K9s+, Q9s+, J9s+, T8s+, 98s, ATo+, KJo+',
      mixed: '33, A6s, K8s, Q8s, 87s, 76s, KTo, QJo',
    ),
    _openRaise(
      tableType: TableType.nineMax,
      position: Position.hj,
      headline: '後ろは 4 人。コネクター類も参加できるようになります。',
      raise: '33+, A5s+, K8s+, Q9s+, J9s+, T8s+, 97s+, 87s, 76s, ATo+, KJo+, QJo',
      mixed: '22, A4s, A3s, K7s, Q8s, J8s, 65s, A9o, KTo, QTo',
    ),
    _openRaise(
      tableType: TableType.nineMax,
      position: Position.co,
      headline: '後ろは BTN とブラインドだけ。ここから一気に広げます。',
      raise:
          '22+, A2s+, K7s+, Q8s+, J8s+, T8s+, 97s+, 86s+, 76s, 65s, A9o+, KTo+, QTo+, JTo',
      mixed: 'K6s, Q7s, J7s, T7s, 54s, A8o, K9o, Q9o',
    ),
    _openRaise(
      tableType: TableType.nineMax,
      position: Position.btn,
      headline: '最も有利な席。9MAX でも BTN のレンジは 6MAX とほぼ同じです。',
      raise:
          '22+, A2s+, K2s+, Q4s+, J6s+, T6s+, 95s+, 85s+, 74s+, 64s+, 53s+, '
          'A2o+, K7o+, Q8o+, J8o+, T8o+, 98o, 87o, 76o',
      mixed: 'Q3s, J5s, T5s, 94s, 84s, 63s, 43s, K6o, Q7o, J7o, 65o',
    ),
    _openRaise(
      tableType: TableType.nineMax,
      position: Position.sb,
      headline: 'BB とのヘッズアップ。広く入れますが、ポストフロップは常に不利です。',
      raise:
          '22+, A2s+, K5s+, Q6s+, J7s+, T7s+, 96s+, 86s+, 75s+, 65s, 54s, '
          'A4o+, K9o+, Q9o+, J9o+, T9o',
      mixed: 'K4s, Q5s, J6s, T6s, A2o, A3o, K8o, Q8o, J8o',
    ),
    _bbDefense(TableType.nineMax),
  ];
}
