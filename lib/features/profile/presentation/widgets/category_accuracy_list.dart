import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/labeled_progress_bar.dart';
import '../../domain/learning_stats.dart';

/// カテゴリ別の正答率一覧。
class CategoryAccuracyList extends StatelessWidget {
  const CategoryAccuracyList({super.key, required this.stats});

  final List<CategoryStat> stats;

  Color _colorFor(CategoryStat stat) {
    if (!stat.hasEnoughSamples) return AppColors.textMuted;
    if (stat.accuracy >= 0.8) return AppColors.success;
    if (stat.accuracy >= 0.6) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final stat in stats)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: LabeledProgressBar(
              label: '${stat.category.label}（${stat.total}問）',
              value: stat.accuracy,
              trailingText: '${(stat.accuracy * 100).round()}%',
              color: _colorFor(stat),
            ),
          ),
      ],
    );
  }
}
