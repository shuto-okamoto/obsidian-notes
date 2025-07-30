# 🚀 Obsidian Notes - App Store Connect 自動デプロイガイド

## ✅ 完了済み
- [x] AppFlowMVP初期化完了
- [x] プロジェクト設定ファイル生成
- [x] UIテスト自動生成（スクリーンショット用）
- [x] ビルドテスト成功
- [x] Bundle ID: `com.obsidian.notes.Obsidian-Notes`
- [x] Team ID: `M925SB5N54`

## 📋 デプロイに必要な手順

### 1. Apple ID認証情報の設定
`.env`ファイルを編集して以下を設定：

```bash
# Apple IDのメールアドレス
FASTLANE_APPLE_ID="あなたのApple ID"

# App-Specific Password (https://appleid.apple.com で生成)
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"

# Match用パスワード（証明書管理用）
MATCH_PASSWORD="your-secure-password"
```

### 2. 証明書管理リポジトリの準備
- GitHubでプライベートリポジトリを作成
- `config/app_config.yml`の`certificates_repo`を更新

### 3. App Store Connectアプリ登録
- https://appstoreconnect.apple.com でアプリを作成
- Bundle ID: `com.obsidian.notes.Obsidian-Notes`
- App名: `Obsidian Notes`

## 🔧 実行コマンド

### セットアップ（初回のみ）
```bash
./setup_enhanced.sh
```

### ビルド
```bash
./build_enhanced.sh
```

### TestFlightにアップロード
```bash
./deploy.sh beta
```

### App Storeリリース
```bash
./deploy.sh release
```

## 📱 生成済みファイル

### UIテスト（スクリーンショット自動生成）
- `ObsidianUITests/ObsidianNotesUITests.swift`
- 以下のスクリーンショットを自動生成：
  - メイン画面
  - メモ作成画面
  - テキスト編集
  - 検索機能
  - テーマ選択
  - 各カラーテーマ

### メタデータ
- 日本語App Store説明文
- キーワード
- スクリーンショット
- プロモーション文

## ⚡ 次のアクション
1. Apple ID認証情報を`.env`に設定
2. `./setup_enhanced.sh`を実行
3. `./deploy.sh beta`でTestFlightにアップロード

準備完了！🎉