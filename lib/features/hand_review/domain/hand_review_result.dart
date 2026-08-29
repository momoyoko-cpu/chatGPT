/// ハンドレビューの結果。仕様書 5-3 の出力 JSON と 1 対 1 で対応する。
class HandReviewResult {
  const HandReviewResult({
    required this.score,
    required this.summary,
    required this.goodPoints,
    required this.mainImprovement,
    required this.streetAnalysis,
    required this.gtoView,
    required this.practicalAdjustment,
    required this.alternativeLines,
    required this.nextFocus,
    required this.relatedQuizTopics,
  });

  /// 0〜100 の総合評価。
  final int score;

  /// 一言レビュー。
  final String summary;
  final List<String> goodPoints;

  /// 一番直したいポイント。
  final String mainImprovement;

  /// ストリート別分析。キーは `preflop` / `flop` / `turn` / `river`。
  final Map<String, String> streetAnalysis;
  final String gtoView;
  final String practicalAdjustment;
  final List<String> alternativeLines;
  final String nextFocus;

  /// 関連クイズのカテゴリ ID 一覧。
  final List<String> relatedQuizTopics;

  factory HandReviewResult.fromJson(Map<String, dynamic> json) {
    return HandReviewResult(
      score: (json['score'] as num?)?.toInt() ?? 0,
      summary: json['summary'] as String? ?? '',
      goodPoints: _stringList(json['good_points']),
      mainImprovement: json['main_improvement'] as String? ?? '',
      streetAnalysis: {
        for (final entry
            in (json['street_analysis'] as Map<String, dynamic>? ?? {}).entries)
          entry.key: entry.value as String? ?? '',
      },
      gtoView: json['gto_view'] as String? ?? '',
      practicalAdjustment: json['practical_adjustment'] as String? ?? '',
      alternativeLines: _stringList(json['alternative_lines']),
      nextFocus: json['next_focus'] as String? ?? '',
      relatedQuizTopics: _stringList(json['related_quiz_topics']),
    );
  }

  Map<String, dynamic> toJson() => {
        'score': score,
        'summary': summary,
        'good_points': goodPoints,
        'main_improvement': mainImprovement,
        'street_analysis': streetAnalysis,
        'gto_view': gtoView,
        'practical_adjustment': practicalAdjustment,
        'alternative_lines': alternativeLines,
        'next_focus': nextFocus,
        'related_quiz_topics': relatedQuizTopics,
      };

  static List<String> _stringList(Object? value) => value is List
      ? value.map((item) => item.toString()).toList(growable: false)
      : const [];
}
