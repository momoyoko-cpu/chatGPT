import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/table_type.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/choice_chip_group.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/fade_slide_in.dart';
import '../application/range_providers.dart';
import '../domain/range_action.dart';
import '../domain/range_guidance.dart';
import '../domain/range_spot.dart';
import 'widgets/hand_detail_sheet.dart';
import 'widgets/range_legend.dart';
import 'widgets/range_matrix.dart';

/// プリフロップレンジ表の画面。
class RangePage extends ConsumerWidget {
  const RangePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableType = ref.watch(selectedTableTypeProvider);
    final position = ref.watch(selectedPositionProvider);
    final chart = ref.watch(selectedRangeChartProvider);
    final positions = Position.orderFor(tableType);

    return Scaffold(
      appBar: AppBar(title: const Text('レンジ表')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.xxl,
          ),
          children: [
            ChoiceChipGroup<TableType>(
              values: TableType.values,
              selected: tableType,
              labelBuilder: (value) => value.label,
              onSelected: (value) => _selectTableType(ref, value),
            ),
            const SizedBox(height: AppSpacing.md),
            ChoiceChipGroup<Position>(
              values: positions,
              selected: position,
              labelBuilder: (value) => value.label,
              onSelected: ref.read(selectedPositionProvider.notifier).select,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (chart == null)
              AppCard(
                child: EmptyState(
                  icon: Icons.grid_off_rounded,
                  title: 'このポジションのレンジ表は準備中です',
                  message: '${position.label} の表は今後のアップデートで追加します。',
                ),
              )
            else ...[
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chart.spot.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${chart.vpipPercent.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      chart.spot.headline,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            '${chart.spot.situation.label} / '
                            '${chart.spot.stackBb.toInt()}BB ・ 学習用の目安として整理した表です',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeSlideIn(
                key: ValueKey(chart.spot.id),
                child: RangeMatrix(
                  chart: chart,
                  onHandTap: (hand) => _showHandDetail(
                    context,
                    ref,
                    chart.spot,
                    RangeGuidanceBuilder.build(
                      spot: chart.spot,
                      entry: chart.entryFor(hand),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: RangeLegend(
                  actions: _legendActions(chart.spot.situation),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                '将来のアップデートで vs Open / vs 3Bet / vs 4Bet を切り替えられるようにします。',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<RangeAction> _legendActions(RangeSituation situation) =>
      situation == RangeSituation.openRaise
      ? const [RangeAction.raise, RangeAction.mixed, RangeAction.fold]
      : const [
          RangeAction.threeBet,
          RangeAction.call,
          RangeAction.mixed,
          RangeAction.fold,
        ];

  void _selectTableType(WidgetRef ref, TableType value) {
    ref.read(selectedTableTypeProvider.notifier).select(value);
    // 9MAX 専用ポジションのまま 6MAX に切り替えると表が無くなるので補正する。
    final positions = Position.orderFor(value);
    final current = ref.read(selectedPositionProvider);
    if (!positions.contains(current)) {
      ref.read(selectedPositionProvider.notifier).select(Position.btn);
    }
  }

  void _showHandDetail(
    BuildContext context,
    WidgetRef ref,
    RangeSpot spot,
    RangeHandGuidance guidance,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      builder: (sheetContext) => HandDetailSheet(
        guidance: guidance,
        spotTitle: spot.title,
        onPractice: () {
          Navigator.of(sheetContext).pop();
          context.go(AppRoutes.quiz);
        },
      ),
    );
  }
}
