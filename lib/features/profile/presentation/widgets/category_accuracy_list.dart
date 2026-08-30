import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/radar_chart.dart';
import '../../domain/learning_stats.dart';

/// カテゴリ別の正答率をレーダーチャートで見せる。
///
/// 10 個の数値を並べるより、形の凹みで苦手が一目で分かる。
class CategoryAccuracyChart extends StatelessWidget {
  const CategoryAccuracyChart({super.key, required this.stats});

  final List<CategoryStat> stats;

  @override
  Widget build(BuildContext context) {
    // 軸の並びは常に同じにして、日によって形が変わって見えないようにする。
    final ordered = [...stats]
      ..sort((a, b) => a.category.index.compareTo(b.category.index));

    return Column(
      children: [
        Center(
          child: RadarChart(
            axes: [
              for (final stat in ordered)
                RadarAxis(
                  label: stat.category.shortLabel,
                  value: stat.accuracy,
                  hasEnoughSamples: stat.hasEnoughSamples,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: AppColors.accent, label: '正答率'),
            const SizedBox(width: AppSpacing.lg),
            _LegendItem(
              color: AppColors.warning.withValues(alpha: 0.7),
              label: '70%ライン',
            ),
          ],
        ),
        const Divider(height: AppSpacing.xl),
        // 数値でも確認できるように、低い順に並べて添える。
        for (final stat in stats)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    stat.category.label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '${stat.total}問',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                SizedBox(
                  width: 42,
                  child: Text(
                    '${(stat.accuracy * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _colorFor(stat),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static Color _colorFor(CategoryStat stat) {
    if (!stat.hasEnoughSamples) return AppColors.textMuted;
    if (stat.accuracy >= 0.8) return AppColors.success;
    if (stat.accuracy >= 0.6) return AppColors.warning;
    return AppColors.danger;
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 3, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
