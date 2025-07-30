#!/bin/bash

# Safe GitHub push script without embedded tokens

echo "🚀 GitHubにObsidian Notesをプッシュしています..."

cd "/Users/okamotohideto/Documents/memo-app/Obsidian Notes"

# 既存のremoteを削除
git remote remove origin 2>/dev/null || true

# 通常のremoteを追加（トークンなし）
git remote add origin https://github.com/shuto-okamoto/obsidian-notes.git

echo "📤 ファイルをプッシュ中..."
echo "※ 認証が必要な場合は、Personal Access Tokenを入力してください"

git push -u origin main

if [ $? -eq 0 ]; then
    echo "✅ プッシュ成功！"
    echo "🎉 GitHubリポジトリURL: https://github.com/shuto-okamoto/obsidian-notes"
    echo "🌐 GitHub Pages: https://shuto-okamoto.github.io/obsidian-notes/"
else
    echo "❌ プッシュに失敗しました"
    exit 1
fi