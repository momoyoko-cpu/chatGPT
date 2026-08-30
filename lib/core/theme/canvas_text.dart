import 'package:flutter/material.dart';

/// CustomPainter の中で文字を描くときの基準スタイル。
///
/// [TextPainter] は [DefaultTextStyle] を引き継がないため、素の [TextStyle] を
/// 渡すと `ThemeData.fontFamily` が効かず、日本語が豆腐（□）になる。
/// キャンバスに文字を描くときは必ずこれを土台にすること。
TextStyle canvasTextStyle(BuildContext context) {
  final theme = Theme.of(context);
  final base = theme.textTheme.bodyMedium ?? const TextStyle();
  return base.copyWith(
    fontFamily: base.fontFamily ?? theme.textTheme.bodyLarge?.fontFamily,
    fontFamilyFallback:
        base.fontFamilyFallback ??
        theme.textTheme.bodyLarge?.fontFamilyFallback,
    height: 1,
  );
}
