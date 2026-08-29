/// テーブル人数の種別。レンジ表・ハンドレビューの両方で共有する。
enum TableType {
  sixMax('6max', '6MAX'),
  nineMax('9max', '9MAX');

  const TableType(this.id, this.label);

  /// Supabase / AI へ渡すときの識別子。
  final String id;

  /// UI 表示用のラベル。
  final String label;

  static TableType fromId(String id) =>
      TableType.values.firstWhere((type) => type.id == id);
}
