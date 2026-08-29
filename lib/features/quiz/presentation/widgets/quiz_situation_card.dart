import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/playing_card_view.dart';
import '../../domain/quiz.dart';

/// クイズのゲーム状況を表示するカード。
class QuizSituationCard extends StatelessWidget {
  const QuizSituationCard({super.key, required this.situation});

  final QuizSituation situation;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _MetaPill(text: situation.tableType.label),
              _MetaPill(text: situation.blindsLabel),
              _MetaPill(text: '${situation.effectiveStackBb.toInt()}BB'),
              _MetaPill(text: 'Pot ${_formatBb(situation.potBb)}BB'),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _PositionBadge(
                label: 'あなた',
                position: situation.heroPosition.label,
                color: AppColors.accent,
              ),
              if (situation.villainPosition != null) ...[
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.swap_horiz_rounded,
                    size: 18, color: AppColors.textMuted),
                const SizedBox(width: AppSpacing.sm),
                _PositionBadge(
                  label: '相手',
                  position: situation.villainPosition!.label,
                  color: AppColors.info,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const _FieldLabel('あなたのハンド'),
          const SizedBox(height: AppSpacing.sm),
          PlayingCardRow(cards: situation.heroCards, width: 44),
          if (situation.board.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _FieldLabel('ボード（${situation.street.label}）'),
            const SizedBox(height: AppSpacing.sm),
            PlayingCardRow(cards: situation.board, width: 38),
          ],
          if (situation.actionHistory.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            const _FieldLabel('アクション履歴'),
            const SizedBox(height: AppSpacing.sm),
            for (final line in situation.actionHistory)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6, right: AppSpacing.sm),
                      child: Icon(Icons.circle,
                          size: 5, color: AppColors.textMuted),
                    ),
                    Expanded(
                      child: Text(
                        line,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  static String _formatBb(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PositionBadge extends StatelessWidget {
  const _PositionBadge({
    required this.label,
    required this.position,
    required this.color,
  });

  final String label;
  final String position;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          Text(
            position,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
