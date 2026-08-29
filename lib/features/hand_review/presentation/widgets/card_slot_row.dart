import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/models/playing_card.dart';
import '../../../../shared/widgets/playing_card_view.dart';

/// カードのスロット表示。タップでピッカーを開く。
class CardSlotRow extends StatelessWidget {
  const CardSlotRow({
    super.key,
    required this.cards,
    required this.slotCount,
    required this.onTap,
    this.cardWidth = 44,
  });

  final List<PlayingCard> cards;
  final int slotCount;
  final VoidCallback onTap;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            for (var i = 0; i < slotCount; i++)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: PlayingCardView(
                  card: i < cards.length ? cards[i] : null,
                  width: cardWidth,
                  onTap: onTap,
                ),
              ),
            const Spacer(),
            const Icon(Icons.touch_app_rounded,
                size: 18, color: AppColors.textMuted),
            const SizedBox(width: AppSpacing.xs),
            const Text(
              'タップして選択',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
