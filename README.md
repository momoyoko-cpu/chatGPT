# AI Poker Coach

> 毎日10分で強くなる。あなた専属のAIポーカーコーチ。

初心者〜中級者向けの No-Limit Texas Hold'em 学習アプリ。
「毎日の10問クイズ → プリフロップレンジ表 → AIハンドレビュー」を
**学習 → 実戦 → 振り返り → 復習** のループにつなげることを目的にしている。

## 現在の状態

仕様書の **Phase 1 / Phase 2 が完了**した状態。
バックエンド未接続で、すべての画面が Mock データで動作する。

| Phase | 内容 | 状態 |
| --- | --- | --- |
| 1 | プロジェクト / Riverpod / GoRouter / Theme / BottomNavigation | 完了 |
| 2 | Home / Quiz / Range / Hand Review / Profile の UI | 完了 |
| 3 | Supabase Auth / DB / Repository 実装 | 未着手（`supabase/schema.sql` を用意済み） |
| 4 | クイズ回答・学習統計のサーバー保存 | 未着手 |
| 5 | レンジ表の DB 連携 | 未着手 |
| 6 | Edge Function 経由の AI ハンドレビュー | 未着手（`docs/ai-prompts.md` に設計済み） |
| 7 | 学習履歴に基づく AI コーチ | ローカル実装のみ |
| 8 | エラーハンドリング / Analytics | 一部（Empty State / Loading） |

## 実装済みの機能

### ホーム
挨拶・レベル・連続学習日数・今日の10問の進捗・AIコーチの一言・
今日の重点テーマ・成長ポイント・苦手分野・最近のハンドレビューを 1 画面にまとめている。

### 毎日の10問クイズ
- 20 問のクイズバンクから、**日付をシードにして毎日同じ 10 問**を出題する
- 学習履歴から算出した**苦手カテゴリを優先**して出題する
- 回答後に「理由 / GTO視点 / 実戦での調整 / よくある初心者のミス」の 4 点セットを表示
- 関連するレンジ表への導線つき
- 10 問終了後に正答率と次回の課題を表示

カテゴリはプリフロップ / フロップ / ターン / リバー / ポジション / ベットサイズ /
ポットオッズ / バリュー・ブラフ / GTO / エクスプロイトの 10 種類。

### プリフロップレンジ表
- 6MAX（5 スポット + BBディフェンス）/ 9MAX（8 スポット + BBディフェンス）
- 169 ハンドの 13x13 マトリクス。ピンチイン / アウトで拡大できる
- Raise / Call / Fold / 3Bet / 4Bet / Mixed を**色と記号の両方**で区別（色覚に依存しない）
- ハンドをタップすると「なぜこのアクションか / 初心者向け / GTO解説 / 実戦での調整」を表示
- レンジは `22+, ATs+, KJo+` のような**レンジ表記**で保持し、実行時に 169 ハンドへ展開する
  （`RangeNotation`）

### AIハンドレビュー
- **テキスト入力をほぼ使わない**タップ中心の入力 UI
  - ゲーム種別 / 人数 / ブラインド / スタックはプリセットのチップ
  - ハンドとボードは 52 枚のカードピッカー（使用済みカードは自動で無効化）
  - 各ストリートのアクションは順にタップして積み上げる
- 結果は仕様書 3-5 の表示順（総合評価 → 一言 → 良かった点 → 一番直したいポイント →
  ストリート別 → GTO視点 → 実戦調整 → 別のライン → 次回の課題 → 関連クイズ）

現在の解析はアプリ内のローカル実装（`MockHandReviewRepository`）で、
プリフロップのレンジ適合・ボード質感・アグレッションから改善点を組み立てている。
**ソルバーの頻度や EV は一切生成しない**（仕様書 14-3）。

### マイページ / 学習履歴
レベル、連続学習日数、解いた問題数、総合正答率、レビュー件数、
直近 7 日 / 30 日の学習日数、得意 / 苦手分野、カテゴリ別の正答率。

## 技術構成

| 領域 | 採用 |
| --- | --- |
| Framework | Flutter 3.47 / Dart 3.13（iOS / Android / Web） |
| State Management | Riverpod 3（`Notifier` / `Provider`） |
| Routing | GoRouter 18（`StatefulShellRoute.indexedStack`） |
| Backend | Supabase（Phase 3 以降） |
| AI | OpenAI API（Supabase Edge Function 経由・Phase 6 以降） |

## ディレクトリ構成

Feature-first。各 feature は `presentation` / `application` / `domain` / `infrastructure`
の 4 層に分かれている。

```
lib/
  app/            アプリのルート・ルーティング・下部タブ
  core/           theme / constants / utils / errors
  shared/         全 feature で共有するモデルとウィジェット
  features/
    home/ quiz/ range_chart/ hand_review/ coach/ profile/ settings/
```

`auth/` は Phase 3（Supabase Authentication 導入）で同じ 4 層構成で追加する。

- `domain/` … モデルとリポジトリの**インターフェース**。Flutter に依存しない
- `infrastructure/` … Mock 実装。Phase 3 以降ここだけを Supabase 実装に差し替える
- `application/` … Riverpod のプロバイダとコントローラ
- `presentation/` … 画面とウィジェット

学習履歴は `LearningStore`（`features/profile/application/learning_providers.dart`）が
唯一の保存場所で、クイズ・ホーム・コーチ・マイページがすべてここを参照している。

## デザイン

- Dark Navy（`#0B111C`）ベース、アクセントは Green（`#2ED3A0`）と Blue（`#4C8DFF`）
- カジノ風に寄せず、学習アプリとしての清潔感を優先
- 角丸カード / 広めの余白 / 数字を大きく
- 操作ボタンの最小タップ領域 44px（`AppSpacing.minTapTarget`）
- レンジ表は色だけに依存せず、アクション記号と凡例を併用

## Web プレビュー

実機やシミュレータを用意しなくても動作を確認できるように、
Flutter Web ビルドを GitHub Pages へ自動公開している
（`.github/workflows/pages.yml`）。公開リポジトリと同様、URL を知っていれば誰でも閲覧できる。

<https://momoyoko-cpu.github.io/chatGPT/>

公開は **`main` へマージされた時点**で自動的に行われる。
GitHub が自動生成する `github-pages` 環境は、既定でデフォルトブランチ以外からの
デプロイを拒否するため、機能ブランチからは公開せず、
ビルド結果を workflow artifact（`web-build`）としてのみ残す。

機能ブランチからもプレビューしたい場合は
**Settings → Environments → github-pages → Deployment branches and tags**
に該当ブランチを追加したうえで、`pages.yml` の `deploy` ジョブの `if` を緩める。

前提となるリポジトリ設定（初回のみ・手動）:
**Settings → Pages → Build and deployment → Source** を `GitHub Actions` にする。

スマートフォン向けのレイアウトなので、PC のブラウザではデベロッパーツールの
デバイスモード（iPhone 等）で見ると実機に近い表示になる。

## 開発

```bash
flutter pub get
flutter run                 # iOS / Android
flutter run -d chrome       # ブラウザ

dart format lib test        # CI で差分チェックあり
flutter analyze             # 警告ゼロを維持する
flutter test                # 67 テスト
```

### テスト

| ファイル | 対象 |
| --- | --- |
| `test/shared/starting_hand_test.dart` | カードと 169 ハンドの分類 |
| `test/features/range_chart/range_notation_test.dart` | レンジ表記の展開 |
| `test/features/range_chart/mock_range_repository_test.dart` | レンジ表の整合性（169 件 / ポジション順にレンジが広がる） |
| `test/features/quiz/daily_quiz_test.dart` | クイズバンクの整合性と 10 問の進行 |
| `test/features/profile/learning_stats_test.dart` | 連続学習日数と苦手分野の算出 |
| `test/features/hand_review/hand_review_test.dart` | 入出力 JSON・ボード質感・解析ロジック |
| `test/app/app_smoke_test.dart` | 5 画面の表示とタブ遷移 |

`flutter analyze` / `flutter test` / `dart format` は push と PR で CI が自動実行する
（`.github/workflows/ci.yml`）。

## バックエンド接続時の注意

1. **OpenAI の API キーはアプリに埋め込まない。** Edge Function からのみ呼ぶ
2. **レンジデータと AI 解説は分離する。** レンジは DB、解説は AI という役割分担を崩さない
3. **AI に正確な GTO 頻度を創作させない。** ソルバー出力が入力にないときは頻度を出さない

DB スキーマは `supabase/schema.sql`、プロンプト設計は `docs/ai-prompts.md` を参照。

## 今後追加したい機能

AI による自動クイズ生成 / Spaced Repetition / Tournament ICM /
Hand History のインポート / スクリーンショット読み取り / Weekly Report /
Achievement / Coach Chat など。
