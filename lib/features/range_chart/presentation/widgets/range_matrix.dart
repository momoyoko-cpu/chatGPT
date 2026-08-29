import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/playing_card.dart';
import '../../../../shared/models/starting_hand.dart';
import '../../domain/range_action.dart';
import '../../domain/range_entry.dart';

/// 169 ハンドの 13x13 マトリクス。
///
/// マス目は画面幅に合わせて縮むため、[InteractiveViewer] で拡大できるようにしている。
/// タップ領域 44px の要件は、周囲の操作ボタン側で担保する。
class RangeMatrix extends StatelessWidget {
  const RangeMatrix({
    super.key,
    required this.chart,
    required this.onHandTap,
  });

  final RangeChart chart;
  final ValueChanged<StartingHand> onHandTap;

  @override
  Widget build(BuildContext context) {
    final ranks = CardRank.descending;

    return InteractiveViewer(
      maxScale: 4,
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth / ranks.length;
            return Column(
              children: [
                for (var row = 0; row < ranks.length; row++)
                  Row(
                    children: [
                      for (var column = 0; column < ranks.length; column++)
                        _MatrixCell(
                          size: cellSize,
                          entry: chart
                              .entryFor(StartingHand.fromGrid(row, column)),
                          onTap: onHandTap,
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MatrixCell extends StatelessWidget {
  const _MatrixCell({
    required this.size,
    required this.entry,
    required this.onTap,
  });

  final double size;
  final RangeEntry entry;
  final ValueChanged<StartingHand> onTap;

  @override
  Widget build(BuildContext context) {
    final isFold = entry.action == RangeAction.fold;
    return SizedBox(
      width: size,
      height: size,
      child: Semantics(
        button: true,
        label: '${entry.hand.code} ${entry.action.label}',
        child: GestureDetector(
          onTap: () => onTap(entry.hand),
          child: Container(
            margin: const EdgeInsets.all(0.5),
            decoration: BoxDecoration(
              color: isFold
                  ? AppColors.rangeFold
                  : entry.action.color.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.hand.code,
                  style: TextStyle(
                    fontSize: size * 0.3,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    color: isFold ? AppColors.textMuted : Colors.white,
                  ),
                ),
                if (!isFold)
                  Text(
                    entry.action.symbol,
                    style: TextStyle(
                      fontSize: size * 0.24,
                      height: 1.05,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
