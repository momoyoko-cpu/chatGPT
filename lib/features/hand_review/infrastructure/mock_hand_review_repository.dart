import '../../../shared/models/poker_action.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/starting_hand.dart';
import '../../range_chart/domain/range_action.dart';
import '../../range_chart/domain/range_repository.dart';
import '../domain/board_texture.dart';
import '../domain/hand_review_input.dart';
import '../domain/hand_review_repository.dart';
import '../domain/hand_review_result.dart';

/// バックエンド接続前に使うローカル解析。
///
/// Phase 6 で Supabase Edge Function 経由の OpenAI 実装に差し替える。
/// ソルバーの頻度や EV は一切生成せず、レンジ表とボード質感から
/// 説明できる範囲のことだけを書く（仕様書 5-1 のルールに従う）。
class MockHandReviewRepository implements HandReviewRepository {
  const MockHandReviewRepository(this._rangeRepository);

  final RangeRepository _rangeRepository;

  @override
  Future<HandReviewResult> review(HandReviewInput input) async {
    // 実際のネットワーク往復に近い体験にするための待ち時間。
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return analyze(input);
  }

  /// テストからも呼べる同期版。
  HandReviewResult analyze(HandReviewInput input) {
    final goodPoints = <String>[];
    final improvements = <String>[];
    final alternatives = <String>[];
    final topics = <String>{};
    var score = 78;

    final preflop = _analyzePreflop(input, goodPoints, improvements, topics);
    score += preflop;

    final postflop = _analyzePostflop(
      input,
      goodPoints,
      improvements,
      alternatives,
      topics,
    );
    score += postflop;

    if (goodPoints.isEmpty) {
      goodPoints.add(
        '最後まで自分のラインを決めて打ち切れています。'
        '判断の良し悪しより先に、迷いを言語化できていることが上達の入り口です。',
      );
    }
    final hasIssue = improvements.isNotEmpty;
    if (!hasIssue) {
      improvements.add(
        '大きな問題は見当たりません。'
        '次は同じスポットで「相手のレンジに何が残っているか」を口に出して確認してみてください。',
      );
    }

    return HandReviewResult(
      score: score.clamp(30, 97),
      summary: _summary(input, improvements.first, hasIssue: hasIssue),
      goodPoints: goodPoints,
      mainImprovement: improvements.first,
      streetAnalysis: _streetAnalysis(input),
      gtoView: _gtoView(input),
      practicalAdjustment: _practicalAdjustment(input),
      alternativeLines: alternatives.isEmpty
          ? ['同じ場面でチェックを選んだ場合、相手の弱いハンドにブラフの余地を残せます。']
          : alternatives,
      nextFocus: _nextFocus(topics, improvements.first),
      relatedQuizTopics: topics.toList(),
    );
  }

  // ------------------------------------------------------------- preflop ----

  int _analyzePreflop(
    HandReviewInput input,
    List<String> goodPoints,
    List<String> improvements,
    Set<String> topics,
  ) {
    if (input.heroHand.length != 2) return 0;
    final hand = StartingHand.fromCards(input.heroHand[0], input.heroHand[1]);
    final heroActions = input.preflop
        .where((action) => action.isHero)
        .toList(growable: false);
    if (heroActions.isEmpty) return 0;

    final chart = _rangeRepository.chartFor(
      input.tableType,
      input.heroPosition,
    );
    final recommended = chart?.entryFor(hand).action;
    final firstAction = heroActions.first.action;

    var delta = 0;

    if (firstAction == PokerActionType.limp) {
      topics.add('preflop');
      improvements.add(
        'プリフロップでリンプ（コールだけで参加）しています。'
        '${input.heroPosition.label} から入るなら、まずレイズで主導権を取る形に統一しましょう。',
      );
      delta -= 8;
      return delta;
    }

    final heroRaised =
        firstAction == PokerActionType.raise ||
        firstAction == PokerActionType.threeBet ||
        firstAction == PokerActionType.fourBet;

    if (recommended == null) {
      return delta;
    }

    if (heroRaised) {
      switch (recommended) {
        case RangeAction.raise:
        case RangeAction.threeBet:
        case RangeAction.fourBet:
          goodPoints.add(
            '${hand.code} は ${input.heroPosition.label} の'
            'レンジにきちんと入っているハンドです。プリフロップの入り方は問題ありません。',
          );
          delta += 6;
        case RangeAction.mixed:
          goodPoints.add(
            '${hand.code} は ${input.heroPosition.label} では境界線上のハンドです。'
            'レイズ自体は間違いではありませんが、テーブルが荒れているときは外してかまいません。',
          );
        case RangeAction.call:
          topics.add('preflop');
          improvements.add(
            '${hand.code} は ${input.heroPosition.label} では'
            'レイズよりもコール寄りのハンドです。レンジ表で位置づけを確認しておきましょう。',
          );
          delta -= 4;
        case RangeAction.fold:
          topics.add('preflop');
          topics.add('position');
          improvements.add(
            '${hand.code} は ${input.heroPosition.label} の'
            'オープンレンジには入りません。ポジションが悪いほど参加ハンドを絞るのが基本です。',
          );
          delta -= 10;
      }
    } else if (firstAction == PokerActionType.call) {
      if (recommended == RangeAction.fold) {
        topics.add('preflop');
        improvements.add(
          '${hand.code} で参加していますが、'
          '${input.heroPosition.label} からはレンジ外です。'
          'ここを絞るだけでポストフロップの難しい判断が減ります。',
        );
        delta -= 8;
      } else if (recommended == RangeAction.raise) {
        topics.add('preflop');
        improvements.add(
          '${hand.code} はレイズできる強さです。'
          'コールで入ると主導権を渡してしまいます。',
        );
        delta -= 5;
      } else {
        goodPoints.add('${hand.code} でのコールは妥当な選択です。');
      }
    }

    return delta;
  }

  // ------------------------------------------------------------ postflop ----

  int _analyzePostflop(
    HandReviewInput input,
    List<String> goodPoints,
    List<String> improvements,
    List<String> alternatives,
    Set<String> topics,
  ) {
    var delta = 0;
    final texture = BoardTexture.of(input.board);
    if (texture == null) return delta;

    final heroPostflopActions = [
      ...input.flop.actions,
      ...input.turn.actions,
      ...input.river.actions,
    ].where((action) => action.isHero).toList(growable: false);

    if (heroPostflopActions.isEmpty) return delta;

    final bigBets = heroPostflopActions
        .where(
          (action) =>
              action.action == PokerActionType.bet75 ||
              action.action == PokerActionType.betPot,
        )
        .length;
    final smallBets = heroPostflopActions
        .where((action) => action.action == PokerActionType.bet33)
        .length;
    final aggressive = heroPostflopActions
        .where(
          (action) =>
              action.action != PokerActionType.check &&
              action.action != PokerActionType.call &&
              action.action != PokerActionType.fold,
        )
        .length;

    if (texture.wetness == BoardWetness.dry && bigBets > 0) {
      topics.add('bet_sizing');
      improvements.add(
        '${texture.wetness.label}ボードで大きめのベットを使っています。'
        'ドローの少ないボードでは、小さいサイズを高頻度で使うほうが機能しやすいスポットです。',
      );
      alternatives.add(
        '同じ場面でポットの 1/3 ほどに落とすと、'
        '相手の弱いハンドを残したままプレッシャーをかけられます。',
      );
      delta -= 6;
    }

    if (texture.wetness == BoardWetness.wet && smallBets > 0 && bigBets == 0) {
      topics.add('bet_sizing');
      improvements.add(
        '${texture.wetness.label}ボードで小さいサイズだけを使っています。'
        'ドローに安くカードを与えてしまうため、強いハンドではサイズを上げましょう。',
      );
      alternatives.add(
        '同じ場面でポットの 3/4 に上げると、'
        'ドローから見て割に合わない値段にできます。',
      );
      delta -= 6;
    }

    if (aggressive == 0) {
      topics.add('value_bluff');
      improvements.add(
        'ポストフロップでチェックとコールだけになっています。'
        '自分から仕掛ける回がないと、勝っている回の利益を取りきれません。',
      );
      delta -= 5;
    } else if (aggressive >= 2) {
      goodPoints.add(
        '複数ストリートで自分から仕掛けられています。'
        'ラインに一貫性があるのは良い点です。',
      );
      delta += 4;
    }

    if (texture.isMonotone) {
      topics.add('flop');
      alternatives.add(
        'モノトーンボードでは、'
        'フラッシュを持っていない側がポットを小さく保つラインも有力です。',
      );
    }

    if (texture.isHighCardBoard && input.heroPosition == Position.bb) {
      topics.add('flop');
      alternatives.add(
        'BB でハイカードボードのときは、'
        'こちらのレンジが不利になりやすいのでチェックを厚めにするのが基本です。',
      );
    }

    return delta;
  }

  // ------------------------------------------------------------ 文章生成 ----

  String _summary(
    HandReviewInput input,
    String mainImprovement, {
    required bool hasIssue,
  }) {
    final head =
        '${input.heroPosition.label} からの${input.lastStreetLabel}までのハンドです。';
    if (!hasIssue) {
      return '$head 目立った問題は見当たりません。'
          'この形は自信を持って同じように打って大丈夫です。';
    }
    return '$head ${mainImprovement.split('。').first}。'
        'ここを直すと、同じ形のハンドがまとめて良くなります。';
  }

  Map<String, String> _streetAnalysis(HandReviewInput input) {
    final texture = BoardTexture.of(input.board);
    return {
      'preflop': input.preflop.isEmpty
          ? 'プリフロップのアクションが未入力です。'
          : 'アクション: ${input.preflop.map((action) => action.toString()).join(' → ')}。'
                '${input.heroPosition.label} のレンジに対して妥当かどうかを、レンジ表と見比べてみてください。',
      'flop': input.flop.cards.isEmpty
          ? 'フロップまで到達していません。'
          : 'ボード: ${input.flop.cards.map((card) => card.display).join(' ')}'
                '（${texture?.wetness.label ?? '判定不能'}）。'
                '${input.flop.actions.isEmpty ? 'アクション未入力。' : 'アクション: ${input.flop.actions.join(' → ')}。'}',
      'turn': input.turn.cards.isEmpty
          ? 'ターンまで到達していません。'
          : 'ターン: ${input.turn.cards.map((card) => card.display).join(' ')}。'
                '${input.turn.actions.isEmpty ? 'アクション未入力。' : 'アクション: ${input.turn.actions.join(' → ')}。'}'
                'ここで相手のレンジがどう絞られたかを確認しましょう。',
      'river': input.river.cards.isEmpty
          ? 'リバーまで到達していません。'
          : 'リバー: ${input.river.cards.map((card) => card.display).join(' ')}。'
                '${input.river.actions.isEmpty ? 'アクション未入力。' : 'アクション: ${input.river.actions.join(' → ')}。'}'
                'バリューかブラフか、目的をはっきりさせて打てていたかを振り返ってください。',
    };
  }

  String _gtoView(HandReviewInput input) {
    final texture = BoardTexture.of(input.board);
    if (texture == null) {
      return 'プリフロップは、ポジションごとに決まったレンジからどれだけ外れていないかがすべてです。'
          'このアプリでは厳密な頻度は表示せず、覚えやすい目安だけを扱っています。';
    }
    return 'このボードは${texture.wetness.label}に分類されます。'
        'レンジ全体で見たときにどちら側が強いかを先に判断し、'
        '有利な側は小さく高頻度、不利な側はチェックを厚く、という骨格で考えます。'
        '正確なソルバー出力は入力に含まれていないため、ここでは頻度の数値は示しません。';
  }

  String _practicalAdjustment(HandReviewInput input) {
    return switch (input.villainProfile) {
      VillainProfile.tight =>
        '相手がタイトなので、ブラフの成功率が上がります。'
            '一方でコールしてきたときは本物であることが多いので、薄いバリューは減らします。',
      VillainProfile.loose =>
        '相手がルーズなので、バリューを厚く、ブラフを薄くします。'
            '相手のレンジが広いぶん、こちらの中程度のハンドの価値も上がります。',
      VillainProfile.passive =>
        '相手が受け身なので、相手からのベットは強さのサインとして重く見ます。'
            'こちらから仕掛ける回を増やすのが有効です。',
      VillainProfile.aggressive =>
        '相手が攻撃的なので、強いハンドでチェックして打たせる形が機能します。'
            'ブラフキャッチの基準も少し緩めてかまいません。',
      VillainProfile.unknown =>
        '相手の情報がないので、まずは標準的なラインを選ぶのが安全です。'
            '数ハンド観察して、降りやすいか / 降りにくいかだけでも掴んでおきましょう。',
    };
  }

  String _nextFocus(Set<String> topics, String mainImprovement) {
    if (topics.contains('preflop')) {
      return 'まずは ${'プリフロップのレンジ'} を固めましょう。'
          'レンジ表で自分のポジションを 1 つ選び、上下の境界だけ覚えるところから始めてください。';
    }
    if (topics.contains('bet_sizing')) {
      return 'ボードの質感とベットサイズの結びつきを練習しましょう。'
          '「ドライなら小さく、ウェットなら大きく」を基準として持っておくと迷いが減ります。';
    }
    if (topics.contains('value_bluff')) {
      return '「このベットはバリューかブラフか」を毎回言葉にしてから打つ練習をしましょう。';
    }
    return mainImprovement;
  }
}
