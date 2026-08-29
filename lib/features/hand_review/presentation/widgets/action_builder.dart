import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/poker_action.dart';

/// アクションをタップで順に追加していくウィジェット。
class ActionBuilder extends StatefulWidget {
  const ActionBuilder({
    super.key,
    required this.actions,
    required this.choices,
    required this.heroLabel,
    required this.villainLabel,
    required this.onAdd,
    required this.onRemoveLast,
  });

  final List<HandAction> actions;
  final List<PokerActionType> choices;
  final String heroLabel;
  final String villainLabel;
  final ValueChanged<HandAction> onAdd;
  final VoidCallback onRemoveLast;

  @override
  State<ActionBuilder> createState() => _ActionBuilderState();
}

class _ActionBuilderState extends State<ActionBuilder> {
  bool _isHeroTurn = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.actions.isNotEmpty) ...[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (var i = 0; i < widget.actions.length; i++)
                _ActionPill(
                  action: widget.actions[i],
                  heroLabel: widget.heroLabel,
                  villainLabel: widget.villainLabel,
                  order: i + 1,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.onRemoveLast,
              icon: const Icon(Icons.undo_rounded, size: 16),
              label: const Text('1つ戻す'),
            ),
          ),
          const Divider(height: AppSpacing.xl),
        ],
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: true, label: Text(widget.heroLabel)),
            ButtonSegment(value: false, label: Text(widget.villainLabel)),
          ],
          selected: {_isHeroTurn},
          onSelectionChanged: (selection) =>
              setState(() => _isHeroTurn = selection.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final choice in widget.choices)
              _ActionButton(
                label: choice.label,
                onTap: () => widget.onAdd(
                  HandAction(
                    actor: _isHeroTurn
                        ? HandAction.heroActor
                        : widget.villainLabel,
                    action: choice,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        // alignment を使うと横幅いっぱいに広がるため Center(widthFactor: 1) を使う。
        child: Container(
          constraints: const BoxConstraints(
            minHeight: AppSpacing.minTapTarget,
            minWidth: 68,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            widthFactor: 1,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    required this.action,
    required this.heroLabel,
    required this.villainLabel,
    required this.order,
  });

  final HandAction action;
  final String heroLabel;
  final String villainLabel;
  final int order;

  @override
  Widget build(BuildContext context) {
    final color = action.isHero ? AppColors.accent : AppColors.info;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$order. ${action.isHero ? heroLabel : villainLabel} ${action.action.label}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
