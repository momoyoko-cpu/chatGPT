import '../../../shared/models/playing_card.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/street.dart';
import '../../../shared/models/table_type.dart';
import '../domain/quiz.dart';
import '../domain/quiz_category.dart';

/// MVP に同梱するクイズ。Phase 4 で Supabase の `quizzes` テーブルへ移す。
///
/// 解説は「短い理由 / GTO視点 / 実戦視点 / よくあるミス」の 4 点セットで持ち、
/// ソルバーの厳密な頻度は書かない（仕様書 14-3）。
abstract final class QuizBank {
  static List<Quiz> get all => List.unmodifiable(_quizzes);

  static Quiz _make({
    required String id,
    required QuizCategory category,
    required QuizDifficulty difficulty,
    required Street street,
    required Position heroPosition,
    Position? villainPosition,
    required String heroCards,
    String board = '',
    double stackBb = 100,
    double potBb = 1.5,
    TableType tableType = TableType.sixMax,
    List<String> actionHistory = const [],
    required String question,
    required List<String> choices,
    required int correctIndex,
    required String shortReason,
    required String gtoView,
    required String practicalView,
    required String commonMistake,
    String? relatedRangeSpotId,
  }) {
    return Quiz(
      id: id,
      category: category,
      difficulty: difficulty,
      situation: QuizSituation(
        tableType: tableType,
        street: street,
        heroPosition: heroPosition,
        villainPosition: villainPosition,
        heroCards: PlayingCard.parseAll(_split(heroCards)),
        board: PlayingCard.parseAll(_split(board)),
        effectiveStackBb: stackBb,
        potBb: potBb,
        actionHistory: actionHistory,
      ),
      question: question,
      choices: [
        for (var i = 0; i < choices.length; i++)
          QuizChoice(id: '$id-c$i', label: choices[i]),
      ],
      correctChoiceId: '$id-c$correctIndex',
      explanation: QuizExplanation(
        shortReason: shortReason,
        gtoView: gtoView,
        practicalView: practicalView,
        commonMistake: commonMistake,
        relatedRangeSpotId: relatedRangeSpotId,
      ),
    );
  }

  static List<String> _split(String cards) => cards.isEmpty
      ? const []
      : cards.split(' ').where((card) => card.isNotEmpty).toList();

  static final List<Quiz> _quizzes = [
    _make(
      id: 'q001',
      category: QuizCategory.preflop,
      difficulty: QuizDifficulty.beginner,
      street: Street.preflop,
      heroPosition: Position.utg,
      heroCards: 'Ad 9c',
      actionHistory: ['あなたにアクションが回ってきた（全員フォールド）'],
      question: 'UTG からのアクションを選んでください。',
      choices: ['Fold', 'Call', 'Raise 2.5BB', 'All-in'],
      correctIndex: 0,
      shortReason: 'A9o は UTG のオープンレンジには入りません。後ろに 5 人残っており、'
          'コールされたときに支配されている（A や 9 が弱い）場面が多くなります。',
      gtoView: 'ソルバーの UTG オープンレンジはオフスートエースだと AJo 前後が下限です。'
          'A9o はその外側にあり、レンジに含めるとレンジ全体の平均的な強さが落ちます。',
      practicalView: '後ろが極端にタイトで、ほとんど誰も参加してこないテーブルなら'
          'A9o のオープンも機能しますが、まずは降りて問題ありません。',
      commonMistake: '「A が付いているから強い」と考えてしまうミスです。'
          'エースは強いですが、キッカーが弱いオフスートエースは'
          'AK・AQ・AJ に支配されやすい形です。',
      relatedRangeSpotId: '6max_utg_open',
    ),
    _make(
      id: 'q002',
      category: QuizCategory.preflop,
      difficulty: QuizDifficulty.beginner,
      street: Street.preflop,
      heroPosition: Position.btn,
      heroCards: 'Kh Th',
      actionHistory: ['UTG〜CO は全員フォールド'],
      question: 'BTN からのアクションを選んでください。',
      choices: ['Fold', 'Call（リンプ）', 'Raise 2.5BB', 'All-in'],
      correctIndex: 2,
      shortReason: 'KTs は BTN のオープンレンジに余裕で入るハンドです。'
          'ポストフロップで必ず最後に動ける有利さを活かし、レイズで主導権を取ります。',
      gtoView: 'BTN のオープンレンジは 40% 以上まで広がるのが一般的で、'
          'KTs はその中でも上位に位置します。',
      practicalView: 'ブラインドが 3Bet を多用する相手でも KTs は降りる必要のない強さです。'
          'ブラインドが受け身ならさらに広げてかまいません。',
      commonMistake: 'リンプ（コールだけで参加）してしまうミスです。'
          'リンプは主導権を渡すうえ、ブラインドに安くフロップを見せてしまいます。',
      relatedRangeSpotId: '6max_btn_open',
    ),
    _make(
      id: 'q003',
      category: QuizCategory.preflop,
      difficulty: QuizDifficulty.intermediate,
      street: Street.preflop,
      heroPosition: Position.bb,
      villainPosition: Position.btn,
      heroCards: 'As 5s',
      potBb: 4,
      actionHistory: ['BTN raise 2.5BB', 'SB fold'],
      question: 'BB です。BTN のオープンに対してどうしますか。',
      choices: ['Fold', 'Call', '3Bet', 'All-in'],
      correctIndex: 2,
      shortReason: 'A5s は 3Bet ブラフの定番です。相手の AA・AK を減らすエースブロッカーを持ち、'
          'コールされてもフラッシュ・ストレートに向かえます。',
      gtoView: 'BB の 3Bet レンジは「強いバリュー + ブロッカーのあるスーテッドエース」で'
          '構成されます。A5s はその後者の代表格です。',
      practicalView: '相手が 4Bet を多用するタイプなら 3Bet ブラフは減らし、'
          '降りない相手（コールが多い）ならコールでフロップを見るのも有力です。',
      commonMistake: 'A5s を「弱いエース」と考えて毎回フォールドしてしまうミスです。'
          'BB はすでにブラインドを払っているため、必要な勝率が下がっている点も忘れないでください。',
      relatedRangeSpotId: '6max_bb_defense',
    ),
    _make(
      id: 'q004',
      category: QuizCategory.position,
      difficulty: QuizDifficulty.beginner,
      street: Street.preflop,
      heroPosition: Position.co,
      villainPosition: Position.utg,
      heroCards: '7h 6h',
      potBb: 4,
      actionHistory: ['UTG raise 2.5BB', 'HJ fold'],
      question: 'CO です。UTG のオープンに対してどうしますか。',
      choices: ['Fold', 'Call', '3Bet', 'All-in'],
      correctIndex: 0,
      shortReason: '76s はオープンできる場面では魅力的ですが、UTG のタイトなレンジに'
          'コールで向かうと、後ろにまだ 3 人残っている状態で不利な戦いになります。',
      gtoView: 'アーリーのオープンに対するコールレンジは、'
          'ポジションと後ろのプレイヤー数の分だけ狭くなります。',
      practicalView: 'UTG が明らかに広くオープンしている相手なら、'
          '76s のコールも成立します。相手のレンジ次第で変わる代表的なスポットです。',
      commonMistake: '「スーテッドコネクターは何でも参加できる」と考えるミスです。'
          '安く見られる場面でこそ価値が出るハンドで、高い値段では割に合いません。',
      relatedRangeSpotId: '6max_co_open',
    ),
    _make(
      id: 'q005',
      category: QuizCategory.potOdds,
      difficulty: QuizDifficulty.beginner,
      street: Street.river,
      heroPosition: Position.bb,
      villainPosition: Position.btn,
      heroCards: 'Qc Qd',
      board: '9h 6s 2d Jc 4c',
      potBb: 12,
      actionHistory: ['リバーで相手がポットの 1/2（6BB）ベット'],
      question: 'ポット 12BB に対して 6BB のベット。コールに必要な勝率はおよそ何%ですか。',
      choices: ['約20%', '約25%', '約33%', '約50%'],
      correctIndex: 1,
      shortReason: 'コール額 6BB ÷（ポット 12 + ベット 6 + コール 6 = 24BB）= 25%。'
          '25% 以上の確率で勝てるならコールが利益になります。',
      gtoView: '相手のベットサイズは、そのままこちらが降りるべき頻度と結びついています。'
          '1/2 ポットベットに対しては、レンジ全体の約 25% 分だけ降りればバランスが取れます。',
      practicalView: '実戦では「25% 勝てるか」を厳密に計算するのではなく、'
          '相手がブラフしそうかどうかで上下させます。ブラフが少ない相手なら降りる寄りです。',
      commonMistake: '分母にコール額を入れ忘れるミスです。'
          '6 ÷ 18 = 33% としてしまうと、必要勝率を高く見積もりすぎます。',
    ),
    _make(
      id: 'q006',
      category: QuizCategory.betSizing,
      difficulty: QuizDifficulty.intermediate,
      street: Street.flop,
      heroPosition: Position.btn,
      villainPosition: Position.bb,
      heroCards: 'Ah Kd',
      board: 'Qs 7d 2c',
      potBb: 5.5,
      actionHistory: ['BTN raise 2.5BB', 'BB call', 'BB check'],
      question: 'このフロップでのベットサイズとして最も適切なものはどれですか。',
      choices: ['Check', 'Bet 33%', 'Bet 75%', 'All-in'],
      correctIndex: 1,
      shortReason: 'Q72 レインボーは相手にとって当たりづらいボードで、'
          'こちらのレンジが有利です。小さいサイズで広く、安くプレッシャーをかけます。',
      gtoView: '乾いた（ドローの少ない）ボードでレンジ有利な側は、'
          '小さいサイズを高頻度で使う形が基本です。',
      practicalView: '相手が小さいベットに何でもコールしてくるタイプなら、'
          '弱いハンドでのベットを減らし、強いハンドでサイズを上げる調整が有効です。',
      commonMistake: 'AK のような「強いけどまだ何もできていない」ハンドで'
          '大きくベットしてしまうミスです。大きく打つと、降りてほしくない弱い手を降ろしてしまいます。',
    ),
    _make(
      id: 'q007',
      category: QuizCategory.betSizing,
      difficulty: QuizDifficulty.intermediate,
      street: Street.flop,
      heroPosition: Position.co,
      villainPosition: Position.bb,
      heroCards: 'Jh Jc',
      board: '9h 8h 5c',
      potBb: 5.5,
      actionHistory: ['CO raise 2.5BB', 'BB call', 'BB check'],
      question: 'このフロップでのベットサイズとして最も適切なものはどれですか。',
      choices: ['Check', 'Bet 33%', 'Bet 75%', 'Fold'],
      correctIndex: 2,
      shortReason: '985 ツートーンはストレートもフラッシュも狙える濡れたボードです。'
          'JJ は今は強いので、ドローに安くカードを与えないよう大きめに打ちます。',
      gtoView: 'ドローが多いボードでは、バリューハンドのベットサイズが大きくなります。'
          '相手のエクイティを安く実現させないことが目的です。',
      practicalView: '相手がドローを追いかけがちなタイプなら、さらに大きく打って問題ありません。'
          '逆にタイトすぎる相手なら、降ろしすぎないようにサイズを落とします。',
      commonMistake: '「オーバーペアだからゆっくり」とチェックしてしまうミスです。'
          'このボードはターンで簡単に逆転されます。',
    ),
    _make(
      id: 'q008',
      category: QuizCategory.flop,
      difficulty: QuizDifficulty.intermediate,
      street: Street.flop,
      heroPosition: Position.btn,
      villainPosition: Position.bb,
      heroCards: 'Ts 9s',
      board: 'Ks 6s 2h',
      potBb: 5.5,
      actionHistory: ['BTN raise 2.5BB', 'BB call', 'BB check'],
      question: 'ナッツフラッシュではないフラッシュドローです。どうしますか。',
      choices: ['Check', 'Bet 33%', 'Bet 75%', 'Fold'],
      correctIndex: 1,
      shortReason: 'フラッシュドローはターン以降で強くなれるので、'
          '今フォールドエクイティを取りつつ、当たったときの支払いも狙えるベットが有効です。',
      gtoView: 'ドローを持ったハンドは、バリューハンドと同じサイズでベットに混ぜることで'
          'レンジ全体のバランスが取れます。',
      practicalView: '相手が K にほとんど降りないタイプなら、'
          'ベットの目的は「降ろすこと」ではなく「当たったときに大きくする準備」に変わります。',
      commonMistake: 'ドローを常にチェックしてしまうミスです。'
          'チェックだけで進めると、当たらなかった回にポットを取る手段がなくなります。',
    ),
    _make(
      id: 'q009',
      category: QuizCategory.flop,
      difficulty: QuizDifficulty.advanced,
      street: Street.flop,
      heroPosition: Position.utg,
      villainPosition: Position.bb,
      heroCards: 'Ac Kd',
      board: '7h 6h 5s',
      potBb: 5.5,
      actionHistory: ['UTG raise 2.5BB', 'BB call', 'BB check'],
      question: 'AK ハイでこのフロップ。どうしますか。',
      choices: ['Check', 'Bet 33%', 'Bet 75%', 'All-in'],
      correctIndex: 0,
      shortReason: '765 は BB のコールレンジに強く当たり、こちらの UTG レンジには当たりません。'
          'レンジ全体が不利な場面では、無理に打たずポットを小さく保ちます。',
      gtoView: 'ボードが相手のレンジに有利な場合、レンジ全体のベット頻度が大きく下がります。'
          'これは「レンジ vs レンジ」で考える典型例です。',
      practicalView: '相手がチェックに対してほとんど打ってこない受け身なタイプなら、'
          '無料でターンを見る価値が上がります。',
      commonMistake: '「オープンしたから毎回コンティニュエーションベット」というミスです。'
          '自分のレンジが当たらないボードでは、打つほど損をします。',
    ),
    _make(
      id: 'q010',
      category: QuizCategory.turn,
      difficulty: QuizDifficulty.intermediate,
      street: Street.turn,
      heroPosition: Position.btn,
      villainPosition: Position.bb,
      heroCards: 'Ah Qh',
      board: 'Kh 8h 3c 2d',
      potBb: 12,
      actionHistory: ['フロップ: BB check → BTN bet 33% → BB call', 'ターン: BB check'],
      question: 'ナッツフラッシュドロー + オーバーカード。ターンでどうしますか。',
      choices: ['Check', 'Bet 33%', 'Bet 75%', 'Fold'],
      correctIndex: 2,
      shortReason: 'ナッツフラッシュドローは、当たれば最強・外しても A ハイが残る強いドローです。'
          'ターンでは大きめに打ち、リバーの大きなポットを作りにいきます。',
      gtoView: 'エクイティの高いドローは、大きいサイズのベットレンジに含まれます。'
          'バリューハンドと同じサイズで打つことで、リバーの選択肢も残ります。',
      practicalView: '相手が K をなかなか降ろさないなら、狙いは「降ろす」ではなく'
          '「フラッシュが完成したときに大きく払わせる」に変わります。',
      commonMistake: 'ドローで小さく打ってしまうミスです。'
          '小さく打つとポットが育たず、当たったときの取り分が減ります。',
    ),
    _make(
      id: 'q011',
      category: QuizCategory.turn,
      difficulty: QuizDifficulty.advanced,
      street: Street.turn,
      heroPosition: Position.co,
      villainPosition: Position.bb,
      heroCards: 'Jd Ts',
      board: 'Ah 7c 4d 2s',
      potBb: 12,
      actionHistory: ['フロップ: BB check → CO bet 33% → BB call', 'ターン: BB check'],
      question: 'JT ハイ、ドローもありません。ターンでどうしますか。',
      choices: ['Check', 'Bet 33%', 'Bet 75%', 'All-in'],
      correctIndex: 0,
      shortReason: 'エクイティもブロッカーもないハンドは、ターンでのブラフに向きません。'
          'チェックしてリバーで安く見せる、あるいは降りる準備をします。',
      gtoView: 'ブラフに選ばれるのは、エクイティが残っているハンドか、'
          '相手の強い手を減らすブロッカーを持つハンドです。JT はそのどちらでもありません。',
      practicalView: '相手がフロップのコールから降りやすいタイプなら、'
          'ターンのブラフも成立します。ただし何を降ろしたいのかは明確にしてください。',
      commonMistake: '「フロップで打ったからターンも打つ」という惰性のブラフです。'
          'ストーリーの通らないブラフはコールされます。',
    ),
    _make(
      id: 'q012',
      category: QuizCategory.river,
      difficulty: QuizDifficulty.intermediate,
      street: Street.river,
      heroPosition: Position.btn,
      villainPosition: Position.bb,
      heroCards: 'Kd Qc',
      board: 'Kc 9s 4h 7d 2c',
      potBb: 16,
      actionHistory: ['フロップ・ターンともに両者チェック', 'リバー: BB check'],
      question: 'トップペア・グッドキッカーでリバーに来ました。どうしますか。',
      choices: ['Check', 'Bet 33%', 'Bet 100%', 'All-in'],
      correctIndex: 1,
      shortReason: '両者がチェックで進んだため相手のレンジは弱めです。'
          '小さいサイズなら、9 やポケットペアなど自分より弱い手からコールをもらえます。',
      gtoView: '相手のレンジが弱いときは、薄いバリューを小さいサイズで取りにいくのが基本です。',
      practicalView: '相手が「何でもコールする」タイプならサイズを上げてかまいません。'
          '逆にリバーで降りやすい相手なら、そもそも打つ価値が下がります。',
      commonMistake: 'チェックで回して価値を取り逃がすミスです。'
          '「負けているかもしれない」という不安で、勝っている回の利益を捨てています。',
    ),
    _make(
      id: 'q013',
      category: QuizCategory.river,
      difficulty: QuizDifficulty.advanced,
      street: Street.river,
      heroPosition: Position.bb,
      villainPosition: Position.btn,
      heroCards: '9c 9d',
      board: 'Ah Kd 6s 3c 2h',
      potBb: 20,
      actionHistory: ['フロップ: BB check → BTN bet → BB call',
          'ターン: BB check → BTN bet → BB call', 'リバー: BB check → BTN が大きくベット（ポットサイズ）'],
      question: '3 ストリート打たれました。99 でどうしますか。',
      choices: ['Fold', 'Call', 'Raise', 'All-in'],
      correctIndex: 0,
      shortReason: '3 回打ち続けるレンジには A や K が多く、99 が勝てる相手はごく限られます。'
          'ポットサイズのベットには 33% の勝率が必要で、それを満たしません。',
      gtoView: 'ブラフキャッチャーとして残すべきなのは、'
          '相手のバリューハンドをブロックしているハンドです。99 は A も K もブロックしていません。',
      practicalView: '相手がリバーでほとんどブラフしない相手なら、なおさら降ります。'
          '逆に極端に攻撃的な相手が明らかなブラフレンジを持つ場合だけ、コールを検討します。',
      commonMistake: '「ここまで払ったから」と最後まで払ってしまうミスです。'
          'すでに入れたチップは判断材料になりません。',
    ),
    _make(
      id: 'q014',
      category: QuizCategory.valueBluff,
      difficulty: QuizDifficulty.intermediate,
      street: Street.turn,
      heroPosition: Position.btn,
      villainPosition: Position.bb,
      heroCards: 'Qs Js',
      board: 'Ks Ts 5d 3h',
      potBb: 12,
      actionHistory: ['フロップ: BB check → BTN bet 33% → BB call', 'ターン: BB check'],
      question: 'ストレートドロー + フラッシュドロー。狙いはどれですか。',
      choices: [
        'バリューベット（今が最強のつもりで打つ）',
        'セミブラフ（降ろす + 当たったときの準備）',
        'ポットコントロールでチェック',
        'ブラフキャッチのためにチェック',
      ],
      correctIndex: 1,
      shortReason: 'QJs は今は QJ ハイですが、A・9・スペードで一気に最強クラスになります。'
          '降ろせれば良し、コールされても次で逆転できるセミブラフです。',
      gtoView: 'セミブラフは「フォールドエクイティ」と「当たったときのエクイティ」の'
          '両方から利益を得ます。ブラフの中でも優先度が高い形です。',
      practicalView: '相手が降りない相手なら、フォールドエクイティは期待できません。'
          'その場合はポットを育てる目的だけで打つ判断になります。',
      commonMistake: 'セミブラフを「ただのブラフ」と考えて、'
          'コールされた瞬間に諦めてしまうミスです。',
    ),
    _make(
      id: 'q015',
      category: QuizCategory.gto,
      difficulty: QuizDifficulty.advanced,
      street: Street.flop,
      heroPosition: Position.co,
      villainPosition: Position.bb,
      heroCards: 'Ad Jd',
      board: 'Ac 8h 3s',
      potBb: 5.5,
      actionHistory: ['CO raise 2.5BB', 'BB call', 'BB check'],
      question: '「レンジ有利」という言葉が意味するのはどれですか。',
      choices: [
        '自分のハンドが相手のハンドより強いこと',
        'そのボードで、自分のレンジ全体が相手のレンジ全体より強いこと',
        '自分のポジションが相手より良いこと',
        'スタックが相手より深いこと',
      ],
      correctIndex: 1,
      shortReason: 'レンジ有利は「今持っている 2 枚」ではなく、'
          'そのボードで自分が持ちうる全ハンドの分布が相手より強い状態を指します。',
      gtoView: 'A 高のボードはオープンした側に AK・AQ・AJ が多く、'
          'BB のコールレンジには A が少ないため、レンジ有利が生まれます。',
      practicalView: 'レンジ有利がある側は、小さいサイズで高頻度に打つのが基本方針になります。'
          '相手が降りない場合だけ、弱い手のベットを減らします。',
      commonMistake: '自分の手札の強さだけでベットを決めてしまうミスです。'
          '相手が何を持ちうるかを含めて考えるのがレンジ思考です。',
    ),
    _make(
      id: 'q016',
      category: QuizCategory.exploit,
      difficulty: QuizDifficulty.beginner,
      street: Street.river,
      heroPosition: Position.btn,
      villainPosition: Position.bb,
      heroCards: '8d 7d',
      board: 'Ks Qh 4c 2s 3h',
      potBb: 14,
      actionHistory: ['相手は「どんなハンドでもコールする」タイプ', 'リバー: BB check'],
      question: '何もできていない 87 ハイ。この相手にどうしますか。',
      choices: ['大きくブラフする', '小さくブラフする', 'Check', 'All-in'],
      correctIndex: 2,
      shortReason: '降りない相手にブラフしても、チップを渡すだけです。'
          'この相手には「バリューを厚く、ブラフをほぼゼロに」が正解になります。',
      gtoView: 'GTO ではリバーのブラフ頻度をバランスさせますが、'
          'それは相手が正しく降りてくることを前提にしています。',
      practicalView: '相手が降りないと分かっているなら、バランスを崩して'
          'バリューベットを増やすのが最も利益になります。これがエクスプロイトです。',
      commonMistake: '「ブラフも混ぜないとバランスが崩れる」と考えて、'
          '降りない相手にブラフしてしまうミスです。',
    ),
    _make(
      id: 'q017',
      category: QuizCategory.exploit,
      difficulty: QuizDifficulty.intermediate,
      street: Street.flop,
      heroPosition: Position.co,
      villainPosition: Position.bb,
      heroCards: '6c 5c',
      board: 'Ah Kd 7s',
      potBb: 5.5,
      actionHistory: ['相手は「フロップで降りやすい」タイトなタイプ', 'BB check'],
      question: '65s で何も当たっていません。このタイトな相手にどうしますか。',
      choices: ['Check', 'Bet 33%', 'Bet 100%', 'Fold'],
      correctIndex: 1,
      shortReason: 'AK7 は相手のコールレンジに当たりにくく、'
          '降りやすい相手なら小さいベットで高い成功率が期待できます。',
      gtoView: 'このボードはオープンした側のレンジ有利が大きく、'
          'GTO でも小さいサイズの高頻度ベットが基本になります。',
      practicalView: 'タイトな相手に対しては、ベットの成功率が上がるぶん'
          'ブラフの本数を増やしてよい場面です。',
      commonMistake: '「何も当たっていないから打てない」と考えるミスです。'
          '重要なのは自分の手の強さではなく、相手が降りるかどうかです。',
    ),
    _make(
      id: 'q018',
      category: QuizCategory.position,
      difficulty: QuizDifficulty.beginner,
      street: Street.preflop,
      heroPosition: Position.sb,
      villainPosition: Position.bb,
      heroCards: 'Kc 9d',
      potBb: 1.5,
      actionHistory: ['全員フォールドで SB のあなたの番'],
      question: 'SB で K9o。どうしますか。',
      choices: ['Fold', 'Call（リンプ）', 'Raise 3BB', 'All-in'],
      correctIndex: 2,
      shortReason: 'SB vs BB のヘッズアップでは K9o はレイズできる強さです。'
          'ポストフロップで不利なぶん、プリフロップで主導権を取ります。',
      gtoView: 'SB のレイズファーストインレンジは 35〜40% 程度まで広がり、'
          'K9o はその中に含まれます。',
      practicalView: 'BB が 3Bet を多用する相手ならレンジを締め、'
          'BB が降りやすい相手ならさらに広げます。',
      commonMistake: 'SB でリンプしてしまうミスです。'
          'リンプすると BB に無料でフロップを見せたうえ、不利なポジションで戦うことになります。',
      relatedRangeSpotId: '6max_sb_open',
    ),
    _make(
      id: 'q019',
      category: QuizCategory.potOdds,
      difficulty: QuizDifficulty.intermediate,
      street: Street.flop,
      heroPosition: Position.bb,
      villainPosition: Position.btn,
      heroCards: 'Jh 9h',
      board: 'Ah 5h 2c',
      potBb: 6,
      actionHistory: ['BTN が 3BB（ポットの 1/2）ベット'],
      question: 'フラッシュドローです。リバーまで見た場合のおおよその完成率は？',
      choices: ['約20%', '約25%', '約35%', '約50%'],
      correctIndex: 2,
      shortReason: 'フラッシュドローのアウツは 9 枚。フロップからリバーまで 2 枚めくれるので、'
          '完成率はおよそ 35% です（アウツ×4 のルール）。',
      gtoView: 'ただし相手にまだベットが残っているため、'
          '「2 枚見られる前提」で計算するのは実際には楽観的すぎる点に注意してください。',
      practicalView: 'ターンでさらに打たれる可能性が高い相手なら、'
          'ターン 1 枚ぶんの約 18% で判断するほうが安全です。',
      commonMistake: 'アウツ×4 のルールを、ターンでも使ってしまうミスです。'
          'ターンからリバーの 1 枚だけなら、アウツ×2 で見積もります。',
    ),
    _make(
      id: 'q020',
      category: QuizCategory.valueBluff,
      difficulty: QuizDifficulty.intermediate,
      street: Street.river,
      heroPosition: Position.co,
      villainPosition: Position.bb,
      heroCards: 'Ac Kc',
      board: 'Kh 9d 4s 4h 2c',
      potBb: 18,
      actionHistory: ['フロップ・ターンでベットしコールされた', 'リバー: BB check'],
      question: 'ツーペア相当（K と 4 のツーペア）でリバー。狙いはどれですか。',
      choices: [
        'バリューベット',
        'ブラフ',
        'ポットコントロールのチェック',
        'ブラフキャッチのチェック',
      ],
      correctIndex: 0,
      shortReason: '相手のレンジには K9・9x・ポケットペアなど、'
          'コールしてくれる弱い手が十分に残っています。バリューベットの場面です。',
      gtoView: '3 ストリート打ち続けるバリューレンジの中でも、'
          'AK はトップキッカーを持つ上位ハンドです。',
      practicalView: '相手が降りやすいタイプならサイズを下げ、'
          '何でもコールするタイプならサイズを上げます。',
      commonMistake: '「4 がペアになって危ない」と考えて止まってしまうミスです。'
          '相手が 4 を持っている組み合わせはごくわずかです。',
    ),
  ];
}
