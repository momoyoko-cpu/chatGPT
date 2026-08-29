import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/quiz.dart';

/// 回答後の解説。GTO視点と実戦視点を分けて表示する。
class QuizExplanationView extends StatelessWidget {
  const QuizExplanationView({
    super.key,
    required this.quiz,
    required this.isCorrect,
    this.onOpenRange,
  });

  final Quiz quiz;
  final bool isCorrect;

  /// 関連するレンジ表を開く。null なら表示しない。
  final VoidCallback? onOpenRange;

  @override
  Widget build(BuildContext context) {
    final explanation = quiz.explanation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          color: (isCorrect ? AppColors.success : AppColors.danger).withValues(
            alpha: 0.1,
          ),
          borderColor: (isCorrect ? AppColors.success : AppColors.danger)
              .withValues(alpha: 0.4),
          child: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: isCorrect ? AppColors.success : AppColors.danger,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrect ? '正解' : '不正解',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isCorrect ? AppColors.success : AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '正しいアクション: ${quiz.correctChoice.label}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ExplanationSection(
          icon: Icons.lightbulb_outline_rounded,
          title: '理由',
          body: explanation.shortReason,
          accent: AppColors.accent,
        ),
        _ExplanationSection(
          icon: Icons.functions_rounded,
          title: 'GTO視点',
          body: explanation.gtoView,
          accent: AppColors.info,
        ),
        _ExplanationSection(
          icon: Icons.sports_esports_rounded,
          title: '実戦での調整',
          body: explanation.practicalView,
          accent: AppColors.warning,
        ),
        _ExplanationSection(
          icon: Icons.error_outline_rounded,
          title: 'よくある初心者のミス',
          body: explanation.commonMistake,
          accent: AppColors.danger,
        ),
        if (onOpenRange != null) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenRange,
              icon: const Icon(Icons.grid_on_rounded, size: 18),
              label: const Text('関連するレンジ表を見る'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ExplanationSection extends StatelessWidget {
  const _ExplanationSection({
    required this.icon,
    required this.title,
    required this.body,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: accent),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14,
                height: 1.7,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
