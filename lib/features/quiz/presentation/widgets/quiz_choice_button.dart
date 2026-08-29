import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// 回答選択肢のボタン。回答後は正解 / 不正解を色と記号の両方で示す。
class QuizChoiceButton extends StatelessWidget {
  const QuizChoiceButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.isRevealed,
    required this.isCorrectChoice,
    required this.isSelected,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isRevealed;
  final bool isCorrectChoice;
  final bool isSelected;

  Color get _borderColor {
    if (!isRevealed) {
      return AppColors.border;
    }
    if (isCorrectChoice) return AppColors.success;
    if (isSelected) return AppColors.danger;
    return AppColors.border;
  }

  Color get _background {
    if (!isRevealed) return AppColors.surface;
    if (isCorrectChoice) return AppColors.success.withValues(alpha: 0.12);
    if (isSelected) return AppColors.danger.withValues(alpha: 0.12);
    return AppColors.surface;
  }

  IconData? get _icon {
    if (!isRevealed) return null;
    if (isCorrectChoice) return Icons.check_circle_rounded;
    if (isSelected) return Icons.cancel_rounded;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: _background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
        child: InkWell(
          onTap: isRevealed ? null : onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
              border: Border.all(
                color: _borderColor,
                width: isRevealed ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
                if (_icon != null)
                  Icon(
                    _icon,
                    size: 22,
                    color: isCorrectChoice
                        ? AppColors.success
                        : AppColors.danger,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
