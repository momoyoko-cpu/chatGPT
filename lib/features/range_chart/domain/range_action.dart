import 'dart:ui';

import '../../../core/theme/app_colors.dart';

/// レンジ表の 1 マスに割り当てるアクション。
///
/// 色覚に依存しないよう、必ず [symbol] を併記して表示する。
enum RangeAction {
  raise('raise', 'Raise', 'R', AppColors.rangeRaise),
  call('call', 'Call', 'C', AppColors.rangeCall),
  fold('fold', 'Fold', 'F', AppColors.rangeFold),
  threeBet('3bet', '3Bet', '3B', AppColors.rangeThreeBet),
  fourBet('4bet', '4Bet', '4B', AppColors.rangeFourBet),
  mixed('mixed', 'Mixed', 'M', AppColors.rangeMixed);

  const RangeAction(this.id, this.label, this.symbol, this.color);

  final String id;
  final String label;

  /// 色に頼らず区別するための記号。
  final String symbol;
  final Color color;

  static RangeAction fromId(String id) =>
      RangeAction.values.firstWhere((action) => action.id == id);
}
