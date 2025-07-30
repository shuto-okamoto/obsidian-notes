# GitHub Repository Setup Instructions

## 手動作業（ユーザーが実行）

### 1. GitHubアカウントでログイン
- https://github.com にアクセス
- あなたのGitHubアカウントでログイン

### 2. 新しいリポジトリを作成
- 右上の「+」ボタンをクリック
- 「New repository」を選択

### 3. リポジトリ設定
- **Repository name**: `obsidian-notes`
- **Description**: `Beautiful Note-Taking App with Dark Theme`
- **Public** を選択（GitHub Pagesを無料で使用するため）
- **Add a README file**: チェックを外す（既にREADME.mdがあるため）
- **Add .gitignore**: None
- **Choose a license**: None

### 4. 「Create repository」ボタンをクリック

### 5. リポジトリのURLをコピー
作成後に表示されるURLをコピーしてください：
```
https://github.com/okamotohideto/obsidian-notes.git
```

## 自動作業（Claude Code が実行）

GitHubリポジトリが作成されたら、以下のコマンドでコードをプッシュします：

```bash
# リモートリポジトリを追加
git remote add origin https://github.com/okamotohideto/obsidian-notes.git

# すべてのファイルをプッシュ
git push -u origin main

# GitHub Pagesを有効化（設定は手動で必要）
```

## GitHub Pages設定（手動）

1. リポジトリページで「Settings」タブをクリック
2. 左側メニューで「Pages」をクリック
3. Source: 「Deploy from a branch」を選択
4. Branch: 「main」を選択
5. Folder: 「/docs」を選択
6. 「Save」をクリック

## 完了後のURL

- **リポジトリ**: https://github.com/okamotohideto/obsidian-notes
- **GitHub Pages サイト**: https://okamotohideto.github.io/obsidian-notes/
- **サポートURL**: https://github.com/okamotohideto/obsidian-notes#support
- **プライバシーURL**: https://github.com/okamotohideto/obsidian-notes#privacy

## 確認事項

GitHubリポジトリ作成後、以下をお知らせください：
1. ✅ リポジトリ作成完了
2. ✅ リポジトリURL取得
3. ✅ GitHub Pages設定完了

その後、Claude CodeがGitプッシュを実行します。