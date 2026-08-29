import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/playing_card.dart';
import '../../../shared/models/poker_action.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/street.dart';
import '../../../shared/models/table_type.dart';
import '../../profile/application/learning_providers.dart';
import '../../range_chart/application/range_providers.dart';
import '../domain/hand_review_input.dart';
import '../domain/hand_review_record.dart';
import '../domain/hand_review_repository.dart';
import '../infrastructure/mock_hand_review_repository.dart';

final handReviewRepositoryProvider = Provider<HandReviewRepository>(
  (ref) => MockHandReviewRepository(ref.watch(rangeRepositoryProvider)),
);

/// ハンドレビューの入力フォーム。すべてタップ操作で更新できるようにする。
class HandReviewForm extends Notifier<HandReviewInput> {
  @override
  HandReviewInput build() => const HandReviewInput();

  void update(HandReviewInput Function(HandReviewInput current) transform) {
    state = transform(state);
  }

  void setGameType(GameType value) => state = state.copyWith(gameType: value);

  void setTableType(TableType value) {
    final positions = Position.orderFor(value);
    state = state.copyWith(
      tableType: value,
      heroPosition: positions.contains(state.heroPosition)
          ? state.heroPosition
          : Position.btn,
      villainPosition: positions.contains(state.villainPosition)
          ? state.villainPosition
          : Position.bb,
    );
  }

  void setBlinds({required double smallBlind, required double bigBlind}) =>
      state = state.copyWith(smallBlind: smallBlind, bigBlind: bigBlind);

  void setEffectiveStack(double value) =>
      state = state.copyWith(effectiveStackBb: value);

  void setHeroPosition(Position value) =>
      state = state.copyWith(heroPosition: value);

  void setVillainPosition(Position value) =>
      state = state.copyWith(villainPosition: value);

  void setVillainProfile(VillainProfile value) =>
      state = state.copyWith(villainProfile: value);

  void setEnvironment(PlayEnvironment value) =>
      state = state.copyWith(environment: value);

  void setUserQuestion(String value) =>
      state = state.copyWith(userQuestion: value);

  /// ヒーローの 2 枚を差し替える。
  void setHeroHand(List<PlayingCard> cards) =>
      state = state.copyWith(heroHand: cards.take(2).toList());

  /// ボードカードを差し替える。
  void setStreetCards(Street street, List<PlayingCard> cards) {
    switch (street) {
      case Street.preflop:
        return;
      case Street.flop:
        state = state.copyWith(flop: state.flop.copyWith(cards: cards));
      case Street.turn:
        state = state.copyWith(turn: state.turn.copyWith(cards: cards));
      case Street.river:
        state = state.copyWith(river: state.river.copyWith(cards: cards));
    }
  }

  void addAction(Street street, HandAction action) =>
      _mutateActions(street, (actions) => [...actions, action]);

  void removeLastAction(Street street) => _mutateActions(
        street,
        (actions) =>
            actions.isEmpty ? actions : actions.sublist(0, actions.length - 1),
      );

  void _mutateActions(
    Street street,
    List<HandAction> Function(List<HandAction> current) transform,
  ) {
    switch (street) {
      case Street.preflop:
        state = state.copyWith(preflop: transform(state.preflop));
      case Street.flop:
        state = state.copyWith(
          flop: state.flop.copyWith(actions: transform(state.flop.actions)),
        );
      case Street.turn:
        state = state.copyWith(
          turn: state.turn.copyWith(actions: transform(state.turn.actions)),
        );
      case Street.river:
        state = state.copyWith(
          river: state.river.copyWith(actions: transform(state.river.actions)),
        );
    }
  }

  void reset() => state = const HandReviewInput();
}

final handReviewFormProvider =
    NotifierProvider<HandReviewForm, HandReviewInput>(HandReviewForm.new);

/// レビュー実行の状態。null は「まだ実行していない」。
class HandReviewController extends Notifier<AsyncValue<HandReviewRecord?>> {
  @override
  AsyncValue<HandReviewRecord?> build() => const AsyncValue.data(null);

  Future<void> submit() async {
    final input = ref.read(handReviewFormProvider);
    if (!input.isSubmittable) return;

    state = const AsyncValue.loading();
    try {
      final result = await ref.read(handReviewRepositoryProvider).review(input);
      final record = HandReviewRecord(
        id: 'review-${DateTime.now().microsecondsSinceEpoch}',
        input: input,
        result: result,
        createdAt: DateTime.now(),
      );
      ref.read(learningStoreProvider.notifier).recordReview(record);
      state = AsyncValue.data(record);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clear() => state = const AsyncValue.data(null);
}

final handReviewControllerProvider =
    NotifierProvider<HandReviewController, AsyncValue<HandReviewRecord?>>(
  HandReviewController.new,
);
