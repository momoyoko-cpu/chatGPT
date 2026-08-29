import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/models/playing_card.dart';
import '../../../shared/models/poker_action.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/street.dart';
import '../../../shared/models/table_type.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/choice_chip_group.dart';
import '../../profile/application/learning_providers.dart';
import '../application/hand_review_providers.dart';
import '../domain/hand_review_input.dart';
import 'widgets/action_builder.dart';
import 'widgets/card_picker_sheet.dart';
import 'widgets/card_slot_row.dart';
import 'widgets/form_section.dart';

/// ハンドレビューの入力画面。テキスト入力を最小限にする。
class HandReviewPage extends ConsumerWidget {
  const HandReviewPage({super.key});

  static const _stackPresets = [30.0, 50.0, 75.0, 100.0, 150.0, 200.0];
  static const _blindPresets = [
    (0.5, 1.0, 'SB 0.5 / BB 1'),
    (1.0, 2.0, 'SB 1 / BB 2'),
    (2.0, 5.0, 'SB 2 / BB 5'),
    (50.0, 100.0, 'SB 50 / BB 100'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(handReviewFormProvider);
    final form = ref.read(handReviewFormProvider.notifier);
    final submission = ref.watch(handReviewControllerProvider);
    final history = ref.watch(handReviewHistoryProvider);
    final positions = Position.orderFor(input.tableType);

    ref.listen(handReviewControllerProvider, (previous, next) {
      if (next.value != null) {
        context.go(AppRoutes.reviewResult);
      }
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('レビューの生成に失敗しました。もう一度お試しください。')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('ハンドレビュー'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: '履歴',
              onPressed: () => _showHistory(context, ref),
              icon: const Icon(Icons.history_rounded),
            ),
          IconButton(
            tooltip: '入力をクリア',
            onPressed: form.reset,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
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
            FormSection(
              title: 'ゲーム',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChoiceChipGroup<GameType>(
                    values: GameType.values,
                    selected: input.gameType,
                    labelBuilder: (value) => value.label,
                    onSelected: form.setGameType,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ChoiceChipGroup<TableType>(
                    values: TableType.values,
                    selected: input.tableType,
                    labelBuilder: (value) => value.label,
                    onSelected: form.setTableType,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ChoiceChipGroup<PlayEnvironment>(
                    values: PlayEnvironment.values,
                    selected: input.environment,
                    labelBuilder: (value) => value.label,
                    onSelected: form.setEnvironment,
                  ),
                ],
              ),
            ),
            FormSection(
              title: 'ブラインド / スタック',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChoiceChipGroup<(double, double, String)>(
                    values: _blindPresets,
                    selected: _blindPresets.firstWhere(
                      (preset) =>
                          preset.$1 == input.smallBlind &&
                          preset.$2 == input.bigBlind,
                      orElse: () => _blindPresets.first,
                    ),
                    labelBuilder: (value) => value.$3,
                    onSelected: (value) => form.setBlinds(
                      smallBlind: value.$1,
                      bigBlind: value.$2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Effective Stack',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ChoiceChipGroup<double>(
                    values: _stackPresets,
                    selected: input.effectiveStackBb,
                    labelBuilder: (value) => '${value.toInt()}BB',
                    onSelected: form.setEffectiveStack,
                  ),
                ],
              ),
            ),
            FormSection(
              title: 'あなたのポジションとハンド',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChoiceChipGroup<Position>(
                    values: positions,
                    selected: input.heroPosition,
                    labelBuilder: (value) => value.label,
                    onSelected: form.setHeroPosition,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  CardSlotRow(
                    cards: input.heroHand,
                    slotCount: 2,
                    onTap: () => _pickCards(
                      context: context,
                      ref: ref,
                      title: 'あなたのハンドを選択',
                      maxCount: 2,
                      current: input.heroHand,
                      onSelected: form.setHeroHand,
                    ),
                  ),
                ],
              ),
            ),
            FormSection(
              title: '相手',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChoiceChipGroup<Position>(
                    values: positions,
                    selected: input.villainPosition,
                    labelBuilder: (value) => value.label,
                    onSelected: form.setVillainPosition,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    '相手の特徴（任意）',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ChoiceChipGroup<VillainProfile>(
                    values: VillainProfile.values,
                    selected: input.villainProfile,
                    labelBuilder: (value) => value.label,
                    onSelected: form.setVillainProfile,
                  ),
                ],
              ),
            ),
            FormSection(
              title: 'Preflop',
              subtitle: 'アクションを順にタップして追加します',
              child: ActionBuilder(
                actions: input.preflop,
                choices: PokerActionType.preflopChoices,
                heroLabel: 'あなた',
                villainLabel: input.villainPosition.label,
                onAdd: (action) => form.addAction(Street.preflop, action),
                onRemoveLast: () => form.removeLastAction(Street.preflop),
              ),
            ),
            _StreetSection(
              title: 'Flop',
              slotCount: 3,
              cards: input.flop.cards,
              actions: input.flop.actions,
              villainLabel: input.villainPosition.label,
              onPickCards: () => _pickCards(
                context: context,
                ref: ref,
                title: 'フロップの3枚を選択',
                maxCount: 3,
                current: input.flop.cards,
                onSelected: (cards) =>
                    form.setStreetCards(Street.flop, cards),
              ),
              onAdd: (action) => form.addAction(Street.flop, action),
              onRemoveLast: () => form.removeLastAction(Street.flop),
            ),
            if (input.flop.cards.length == 3)
              _StreetSection(
                title: 'Turn',
                slotCount: 1,
                cards: input.turn.cards,
                actions: input.turn.actions,
                villainLabel: input.villainPosition.label,
                onPickCards: () => _pickCards(
                  context: context,
                  ref: ref,
                  title: 'ターンの1枚を選択',
                  maxCount: 1,
                  current: input.turn.cards,
                  onSelected: (cards) =>
                      form.setStreetCards(Street.turn, cards),
                ),
                onAdd: (action) => form.addAction(Street.turn, action),
                onRemoveLast: () => form.removeLastAction(Street.turn),
              ),
            if (input.turn.cards.length == 1)
              _StreetSection(
                title: 'River',
                slotCount: 1,
                cards: input.river.cards,
                actions: input.river.actions,
                villainLabel: input.villainPosition.label,
                onPickCards: () => _pickCards(
                  context: context,
                  ref: ref,
                  title: 'リバーの1枚を選択',
                  maxCount: 1,
                  current: input.river.cards,
                  onSelected: (cards) =>
                      form.setStreetCards(Street.river, cards),
                ),
                onAdd: (action) => form.addAction(Street.river, action),
                onRemoveLast: () => form.removeLastAction(Street.river),
              ),
            FormSection(
              title: '迷ったポイント（任意）',
              subtitle: '入力しなくてもレビューできます',
              child: TextField(
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '例）ターンでベットサイズを大きくしすぎた気がする',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceHigh,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
                onChanged: form.setUserQuestion,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.icon(
              onPressed: input.isSubmittable && !submission.isLoading
                  ? ref.read(handReviewControllerProvider.notifier).submit
                  : null,
              icon: submission.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(submission.isLoading ? '分析中…' : 'AIレビューを実行'),
            ),
            if (!input.isSubmittable) ...[
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'ハンド2枚とプリフロップのアクションを入力すると実行できます。',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickCards({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required int maxCount,
    required List<PlayingCard> current,
    required ValueChanged<List<PlayingCard>> onSelected,
  }) async {
    final input = ref.read(handReviewFormProvider);
    final used = {...input.heroHand, ...input.board}..removeAll(current);
    final selection = await showCardPicker(
      context,
      title: title,
      maxCount: maxCount,
      initialSelection: current,
      disabledCards: used,
    );
    if (selection != null) onSelected(selection);
  }

  void _showHistory(BuildContext context, WidgetRef ref) {
    final history = ref.read(handReviewHistoryProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      builder: (context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const Text(
              'レビュー履歴',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final record in history)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              record.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            '${record.score} / 100',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        record.result.summary,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StreetSection extends StatelessWidget {
  const _StreetSection({
    required this.title,
    required this.slotCount,
    required this.cards,
    required this.actions,
    required this.villainLabel,
    required this.onPickCards,
    required this.onAdd,
    required this.onRemoveLast,
  });

  final String title;
  final int slotCount;
  final List<PlayingCard> cards;
  final List<HandAction> actions;
  final String villainLabel;
  final VoidCallback onPickCards;
  final ValueChanged<HandAction> onAdd;
  final VoidCallback onRemoveLast;

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: title,
      subtitle: 'ボードを選ぶとアクションを入力できます',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardSlotRow(
            cards: cards,
            slotCount: slotCount,
            onTap: onPickCards,
            cardWidth: 40,
          ),
          if (cards.length == slotCount) ...[
            const Divider(height: AppSpacing.xl),
            ActionBuilder(
              actions: actions,
              choices: PokerActionType.postflopChoices,
              heroLabel: 'あなた',
              villainLabel: villainLabel,
              onAdd: onAdd,
              onRemoveLast: onRemoveLast,
            ),
          ],
        ],
      ),
    );
  }
}
