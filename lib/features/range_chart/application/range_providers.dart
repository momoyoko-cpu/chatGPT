import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/position.dart';
import '../../../shared/models/table_type.dart';
import '../domain/range_entry.dart';
import '../domain/range_repository.dart';
import '../infrastructure/mock_range_repository.dart';

final rangeRepositoryProvider = Provider<RangeRepository>(
  (ref) => const MockRangeRepository(),
);

/// レンジ表で選択中のテーブル人数。
class TableTypeSelection extends Notifier<TableType> {
  @override
  TableType build() => TableType.sixMax;

  void select(TableType tableType) => state = tableType;
}

final selectedTableTypeProvider =
    NotifierProvider<TableTypeSelection, TableType>(TableTypeSelection.new);

/// レンジ表で選択中のポジション。
class PositionSelection extends Notifier<Position> {
  @override
  Position build() => Position.btn;

  void select(Position position) => state = position;
}

final selectedPositionProvider = NotifierProvider<PositionSelection, Position>(
  PositionSelection.new,
);

/// 現在の選択に対応するレンジ表。
final selectedRangeChartProvider = Provider<RangeChart?>((ref) {
  final tableType = ref.watch(selectedTableTypeProvider);
  final position = ref.watch(selectedPositionProvider);
  return ref.watch(rangeRepositoryProvider).chartFor(tableType, position);
});

/// スポット ID を指定して取得する（クイズ解説からのリンク用）。
final rangeChartByIdProvider = Provider.family<RangeChart?, String>((
  ref,
  spotId,
) {
  return ref.watch(rangeRepositoryProvider).chartById(spotId);
});
