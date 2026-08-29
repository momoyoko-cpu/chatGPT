import '../../../shared/models/position.dart';
import '../../../shared/models/table_type.dart';
import 'range_entry.dart';
import 'range_spot.dart';

/// レンジ表の取得口。Mock と Supabase 実装を差し替えられるようにする。
abstract interface class RangeRepository {
  /// そのテーブル人数で利用できるスポット一覧。
  List<RangeSpot> spotsFor(TableType tableType);

  /// ポジションに対応するレンジ表。存在しなければ null。
  RangeChart? chartFor(TableType tableType, Position position);

  /// スポット ID から直接取得する（クイズ解説からのリンク用）。
  RangeChart? chartById(String spotId);
}
