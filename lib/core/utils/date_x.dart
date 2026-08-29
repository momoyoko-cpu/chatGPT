/// 日付まわりの共通処理。
extension DateOnly on DateTime {
  /// 時刻を落とした日付。学習日の比較に使う。
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

/// 連続学習日数を求める。
///
/// 今日または昨日を起点に、日付が 1 日ずつ連続している分だけ数える。
int calculateStreak(Set<DateTime> activeDays, {DateTime? today}) {
  if (activeDays.isEmpty) return 0;
  final normalized = activeDays.map((day) => day.dateOnly).toSet();
  final base = (today ?? DateTime.now()).dateOnly;

  var cursor = normalized.contains(base)
      ? base
      : base.subtract(const Duration(days: 1));
  if (!normalized.contains(cursor)) return 0;

  var streak = 0;
  while (normalized.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}
