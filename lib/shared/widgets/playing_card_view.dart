import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../models/playing_card.dart';

/// トランプ 1 枚の表示。ボードやヒーローハンドの表示に使う。
class PlayingCardView extends StatelessWidget {
  const PlayingCardView({
    super.key,
    required this.card,
    this.width = 40,
    this.onTap,
  });

  /// null のときは裏面（未選択スロット）として表示する。
  final PlayingCard? card;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currentCard = card;
    final isRed = currentCard?.suit.isRed ?? false;
    final height = width * 1.4;

    return Semantics(
      button: onTap != null,
      label: currentCard == null ? 'カード未選択' : currentCard.display,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: currentCard == null ? AppColors.surfaceHigh : Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm * 0.7),
            border: Border.all(
              color: currentCard == null
                  ? AppColors.border
                  : Colors.white.withValues(alpha: 0.6),
            ),
          ),
          child: currentCard == null
              ? const Icon(Icons.add, size: 18, color: AppColors.textMuted)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      currentCard.rank.symbol,
                      style: TextStyle(
                        fontSize: width * 0.46,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: isRed
                            ? const Color(0xFFD03A3A)
                            : const Color(0xFF16202E),
                      ),
                    ),
                    Text(
                      currentCard.suit.symbol,
                      style: TextStyle(
                        fontSize: width * 0.38,
                        height: 1.1,
                        color: isRed
                            ? const Color(0xFFD03A3A)
                            : const Color(0xFF16202E),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// カードを横並びで表示する。
class PlayingCardRow extends StatelessWidget {
  const PlayingCardRow({
    super.key,
    required this.cards,
    this.width = 40,
    this.spacing = AppSpacing.sm,
  });

  final List<PlayingCard> cards;
  final double width;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final card in cards) PlayingCardView(card: card, width: width),
      ],
    );
  }
}
