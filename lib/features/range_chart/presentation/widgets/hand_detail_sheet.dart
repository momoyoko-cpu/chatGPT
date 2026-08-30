import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/collapsible_section.dart';
import '../../domain/range_action.dart';
import '../../domain/range_guidance.dart';

/// ハンドをタップしたときに出す詳細シート。
class HandDetailSheet extends StatelessWidget {
  const HandDetailSheet({
    super.key,
    required this.guidance,
    required this.spotTitle,
    this.onPractice,
  });

  final RangeHandGuidance guidance;
  final String spotTitle;

  /// 関連クイズを解く導線。
  final VoidCallback? onPractice;

  @override
  Widget build(BuildContext context) {
    final color = guidance.action == RangeAction.fold
        ? AppColors.textMuted
        : guidance.action.color;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                spotTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    guidance.hand.code,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: color.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      '${guidance.action.symbol}  ${guidance.action.label}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${guidance.hand.description} ・ ${guidance.frequencyLabel}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Section(title: 'なぜこのアクションか', body: guidance.reason),
              // 補足はタップで開く。開いた瞬間の文字量を抑える。
              CollapsibleSection(
                icon: Icons.school_rounded,
                title: '初心者向け',
                body: guidance.beginnerNote,
                accent: AppColors.accent,
              ),
              CollapsibleSection(
                icon: Icons.functions_rounded,
                title: 'GTO解説',
                body: guidance.gtoNote,
                accent: AppColors.info,
              ),
              CollapsibleSection(
                icon: Icons.sports_esports_rounded,
                title: '実戦での調整',
                body: guidance.practicalNote,
                accent: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.md),
              if (onPractice != null) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onPractice,
                    icon: const Icon(Icons.school_rounded, size: 18),
                    label: const Text('関連クイズを解く'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
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
    );
  }
}
