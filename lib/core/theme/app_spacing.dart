/// 余白と角丸の共通値。仕様書の「余白を広め」「角丸カード」に対応する。
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 22;

  /// 仕様書で定めた最小タップ領域。
  static const double minTapTarget = 44;
}
