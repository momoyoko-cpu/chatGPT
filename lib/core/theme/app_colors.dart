import 'package:flutter/material.dart';

/// アプリ全体のカラーパレット。
///
/// 仕様書のデザイン方針に合わせて Dark Navy をベースにし、
/// カジノらしい赤金ではなく学習アプリらしい清潔感のある配色にする。
abstract final class AppColors {
  /// 画面の一番下地。
  static const Color background = Color(0xFF0B111C);

  /// カード / パネルの背景。背景より少し明るいダークグレー。
  static const Color surface = Color(0xFF141C2B);

  /// カードの中に重ねるさらに一段明るい面。
  static const Color surfaceHigh = Color(0xFF1D2739);

  /// 境界線。
  static const Color border = Color(0xFF27334A);

  /// メインのアクセント（Green 系）。
  static const Color accent = Color(0xFF2ED3A0);
  static const Color accentDark = Color(0xFF14A87C);

  /// サブのアクセント（Blue 系）。
  static const Color info = Color(0xFF4C8DFF);

  static const Color textPrimary = Color(0xFFF2F5FA);
  static const Color textSecondary = Color(0xFFA6B1C4);
  static const Color textMuted = Color(0xFF6E7B92);

  static const Color success = Color(0xFF2ED3A0);
  static const Color warning = Color(0xFFF2B544);
  static const Color danger = Color(0xFFF2685C);

  /// レンジ表のアクション色。
  /// 色だけに頼らないよう、必ず記号ラベルと併用すること。
  static const Color rangeRaise = Color(0xFFE0655B);
  static const Color rangeCall = Color(0xFF3FA96F);
  static const Color rangeFold = Color(0xFF2A3448);
  static const Color rangeThreeBet = Color(0xFF8F6BE0);
  static const Color rangeFourBet = Color(0xFFC04A8A);
  static const Color rangeMixed = Color(0xFFD9A441);
}
