import 'dart:math';

import '../domain/quiz.dart';
import '../domain/quiz_category.dart';
import '../domain/quiz_repository.dart';
import 'quiz_bank.dart';

/// アプリ同梱のクイズを返すリポジトリ。
///
/// Phase 4 で Supabase の `quizzes` テーブルに置き換える。
class MockQuizRepository implements QuizRepository {
  const MockQuizRepository();

  @override
  List<Quiz> all() => QuizBank.all;

  @override
  List<Quiz> byCategory(QuizCategory category) =>
      QuizBank.all.where((quiz) => quiz.category == category).toList();

  @override
  List<Quiz> dailyQuizzes(
    DateTime date, {
    int count = 10,
    List<QuizCategory> weakCategories = const [],
  }) {
    final pool = [...QuizBank.all];
    // 日付をシードにして、同じ日なら必ず同じ 10 問になるようにする。
    final seed = date.year * 10000 + date.month * 100 + date.day;
    pool.shuffle(Random(seed));

    // 苦手カテゴリを前方へ寄せる。AI コーチの「今日の重点テーマ」を出題に反映する導線。
    // sort は安定性が保証されないため、分割して連結する。
    final ordered = weakCategories.isEmpty
        ? pool
        : [
            ...pool.where((quiz) => weakCategories.contains(quiz.category)),
            ...pool.where((quiz) => !weakCategories.contains(quiz.category)),
          ];

    return ordered.take(min(count, ordered.length)).toList();
  }
}
