import 'quiz.dart';
import 'quiz_category.dart';

/// クイズの取得口。Mock と Supabase 実装を差し替えられるようにする。
abstract interface class QuizRepository {
  /// 出題可能なクイズすべて。
  List<Quiz> all();

  /// その日の 10 問。同じ日付なら必ず同じ並びになる。
  ///
  /// [weakCategories] を渡すと、その分野を優先的に出題する。
  List<Quiz> dailyQuizzes(
    DateTime date, {
    int count = 10,
    List<QuizCategory> weakCategories = const [],
  });

  /// カテゴリを指定して復習する（クイズ解説やレビュー結果からの導線）。
  List<Quiz> byCategory(QuizCategory category);
}
