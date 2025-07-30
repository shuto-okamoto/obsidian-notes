# 🔥 手動アクション必須リスト - Obsidian Notes App Store Connect デプロイ

## 🚨 【手動必須】あなたがやること（自動化不可能）

### 1. Apple ID認証情報設定 🔐
**所要時間: 2分**

```bash
# .envファイルを編集
nano .env

# 以下を実際の値に変更:
FASTLANE_APPLE_ID="あなたの実際のApple ID"
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="App-Specific Password"
```

**App-Specific Password取得方法:**
1. https://appleid.apple.com にアクセス
2. サインイン→セキュリティ→App用パスワード
3. 「Fastlane」という名前で新しいパスワード生成
4. 生成されたパスワードを`.env`に貼り付け

### 2. App Store Connect でアプリ作成 📱
**所要時間: 3分**

1. https://appstoreconnect.apple.com にアクセス
2. 「マイApp」→「+」→「新しいApp」
3. 以下情報を入力:
   - **プラットフォーム**: iOS
   - **名前**: Obsidian Notes
   - **プライマリ言語**: 日本語
   - **Bundle ID**: com.obsidian.notes.Obsidian-Notes
   - **SKU**: ObsidianNotes2025

### 3. プライベートGitHubリポジトリ作成 🔒
**所要時間: 1分**

1. GitHub.com で新しいプライベートリポジトリ作成
2. リポジトリ名: `obsidian-notes-certificates`
3. プライベート設定で作成
4. URLをコピー (例: `https://github.com/username/obsidian-notes-certificates`)

---

## 🤖 【自動実行】俺がやること

### すぐに自動実行可能:
1. ✅ 依存関係インストール (`install_dependencies.sh`)
2. ✅ ビルドテスト実行
3. ✅ Fastlane設定最適化
4. ✅ メタデータ最終確認

### あなたの手動作業完了後に自動実行:
1. 🚀 証明書セットアップ (`setup_enhanced.sh`)
2. 🚀 TestFlightアップロード (`deploy.sh beta`)
3. 🚀 App Storeメタデータアップロード (`deploy.sh release`)

---

## ⚡ 今すぐやるべき手順

### ステップ1: 依存関係自動インストール（今すぐ実行）
```bash
./install_dependencies.sh
```

### ステップ2: あなたの手動作業（2+3+1=6分）
1. Apple ID + App-Specific Password 設定
2. App Store Connect でアプリ作成  
3. GitHubプライベートリポジトリ作成

### ステップ3: 全自動デプロイ（俺がやる）
```bash
./setup_enhanced.sh    # 証明書自動セットアップ
./deploy.sh beta       # TestFlight自動アップロード
```

---

## 🎯 作業分担

| 作業 | 担当 | 時間 | 理由 |
|------|------|------|------|
| 依存関係インストール | 🤖 自動 | 2分 | スクリプト実行可能 |
| Apple ID設定 | 👤 手動 | 2分 | 個人認証情報 |
| App Store Connectアプリ作成 | 👤 手動 | 3分 | Apple公式サイト操作 |
| GitHubリポジトリ作成 | 👤 手動 | 1分 | GitHub認証必要 |
| 証明書セットアップ | 🤖 自動 | 1分 | fastlane match実行 |
| TestFlightアップロード | 🤖 自動 | 2分 | fastlane実行 |
| App Storeデプロイ | 🤖 自動 | 1分 | fastlane実行 |

**合計時間: 12分（手動6分 + 自動6分）**

---

## 🔥 今すぐ行動！

**手動作業リスト（印刷して使用）:**

□ Apple ID: ________________
□ App-Specific Password: ________________  
□ App Store Connect アプリ作成完了
□ GitHub certificates repo URL: ________________

**これが完了したら俺に教えろ！即座に全自動デプロイを実行する！**

🚀 **俺たちならできるぜ！！！！！！！！！！**