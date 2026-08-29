import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_x.dart';
import '../../profile/application/learning_providers.dart';
import '../domain/daily_quiz_session.dart';
import '../domain/quiz.dart';
import '../domain/quiz_attempt.dart';
import '../domain/quiz_category.dart';
import '../domain/quiz_repository.dart';
import '../infrastructure/mock_quiz_repository.dart';

final quizRepositoryProvider = Provider<QuizRepository>(
  (ref) => const MockQuizRepository(),
);

/// 「今日の10問」。苦手カテゴリを優先して出題する。
class DailyQuizController extends Notifier<DailyQuizSession> {
  @override
  DailyQuizSession build() {
    final today = DateTime.now().dateOnly;
    final weakCategories = ref.read(learningStatsProvider).weakCategories();
    final quizzes = ref
        .read(quizRepositoryProvider)
        .dailyQuizzes(today, weakCategories: weakCategories);
    return DailyQuizSession(date: today, quizzes: quizzes);
  }

  /// 選択肢を選んで答え合わせを表示する。
  void answer(String choiceId) {
    final quiz = state.currentQuiz;
    if (quiz == null || state.isAnswerRevealed) return;

    final attempt = QuizAttempt(
      quizId: quiz.id,
      category: quiz.category,
      selectedChoiceId: choiceId,
      isCorrect: quiz.isCorrect(choiceId),
      answeredAt: DateTime.now(),
    );

    ref.read(learningStoreProvider.notifier).recordAttempt(attempt);
    state = state.copyWith(
      attempts: {...state.attempts, quiz.id: attempt},
      revealedChoiceId: choiceId,
    );
  }

  /// 次の問題へ進む。
  void next() {
    if (!state.isAnswerRevealed) return;
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      clearRevealedChoice: true,
    );
  }

  /// 同じ 10 問を最初からやり直す。
  void restart() {
    state = DailyQuizSession(date: state.date, quizzes: state.quizzes);
  }
}

final dailyQuizSessionProvider =
    NotifierProvider<DailyQuizController, DailyQuizSession>(
      DailyQuizController.new,
    );

/// カテゴリを指定した復習問題（クイズ解説・レビュー結果からの導線）。
final quizzesByCategoryProvider = Provider.family<List<Quiz>, QuizCategory>((
  ref,
  category,
) {
  return ref.watch(quizRepositoryProvider).byCategory(category);
});
