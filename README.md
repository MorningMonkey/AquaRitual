<div align="center">
  <img src="assets/header_cropped_text.png" alt="AquaRitual Header" width="100%" />
</div>

# AquaRitual

水槽の育成体験で、日々の習慣化（ストリーク）を静かに継続できるアプリ。

## 想定プラットフォーム（仮）
- 対象: iOS / Web（必要ならPWA含む）
- 最優先: iOS
- 画面前提: モバイル優先 / レスポンシブ対応

> [!IMPORTANT]
> このリポジトリは **Convoy 管理下**で運用します。ワークフロー定義（`.agent/`）は本リポジトリには含めず、Convoy本体のワークフローを参照して進行します。

> [!NOTE]
> 実行フロー: `/branding-intake` → brief確定 → `/update-convoy-identity` → `/review-repo-quality` → 実装（例: `/build-app-simple`）


## Quick Start
```bash
# Install dependencies
pnpm install

# Start development server
pnpm dev
```

## Core Features
- **iPhone Native**: SwiftUI によるネイティブ実装・動画背景サポート
- **Habit Streaks**: 日々の習慣をストリークとして可視化
- **Aquarium Focus**: 1080p動画背景による圧倒的な水槽体験
- **Focus Timer**: 集中セッション用タイマー（HUD）
- **Glass UI**: 視認性を確保するガラスオーバーレイ
- **Web MVP**: Web版（Vanilla JS）も同梱

## iOS App Build (SwiftUI)
ソースコードは `ios/AquaRitual/` にあります。

### 1. プロジェクト作成
Xcode で新規プロジェクト（App / SwiftUI / Swift）を作成し、`AquaRitual` と命名します。
`ios/AquaRitual/` 配下のファイル（Views, ViewModels, Resources 等）を Xcode プロジェクトに追加してください。

### 2. 動画ファイルの配置
`ios/AquaRitual/Resources/aquarium_loop_1080p.mp4` はプレースホルダーです。
実機ビルドの前に、本物の動画ファイル（1920x1080, H.264/HEVC, 無音推奨）に差し替えてください。

### 3. タイマー仕様
- **Start**: カウントアップ開始
- **Pause**: 一時停止（再開可能）
- **Stop**: リセット（00:00に戻る）

### 4. 報酬システム (Reward System)
- **Fish**: 習慣達成（チェックON）で1日最大2匹まで魚がスポーンします（上限12匹）。
- **Plants**: 今日の達成率（%）に応じて、水草の背丈が成長します。日付変更でリセット。
- **Decor**: ストリーク（連続達成記録）に応じてデコレーションが解放されます。
  - 7 Days: Rock (Small)
  - 14 Days: Driftwood
  - 30 Days: Shell

## Docs
- [Branding Brief](assets/branding/aqua-ritual/brief.md)
- [Architecture](docs/architecture.drawio)

## Convoy Workflows
- このリポジトリには `.agent/` を含めません（Convoy本体リポジトリ側を参照）。
- ワークフロー: Convoy本体の `.agent/workflows/` を参照（例: branding-intake / update-convoy-identity / review-repo-quality）

