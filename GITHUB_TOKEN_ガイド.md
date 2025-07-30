# 🔑 GitHub Personal Access Token 作成ガイド

## ステップ1️⃣: GitHub Settingsにアクセス

1. **GitHub.com** で右上のプロフィール写真をクリック
2. **「Settings」** をクリック

## ステップ2️⃣: Developer settingsへ移動

1. 左側メニューの**一番下**までスクロール
2. **「Developer settings」** をクリック

## ステップ3️⃣: Personal Access Token作成

1. **「Personal access tokens」** をクリック
2. **「Tokens (classic)」** をクリック
3. **「Generate new token」** をクリック
4. **「Generate new token (classic)」** を選択

## ステップ4️⃣: Token設定

### 📝 入力項目
- **Note**: `Obsidian Notes Upload` と入力
- **Expiration**: `30 days` を選択

### ☑️ 権限設定（重要！）
**「repo」にチェック** ✅
- これだけで十分です

## ステップ5️⃣: Token生成

1. **「Generate token」** をクリック
2. **生成されたトークンをコピー** 📋
   - `ghp_` で始まる長い文字列
   - ⚠️ このページを閉じると二度と見れません！

## ステップ6️⃣: ターミナルでプッシュ

```bash
cd "/Users/okamotohideto/Documents/memo-app/Obsidian Notes"
git push -u origin main
```

### 🔑 認証情報
- **Username**: `shuto-okamoto`
- **Password**: 生成したトークンをペースト（ghp_...）

## 🎯 成功確認

プッシュ成功後、ブラウザで確認：
https://github.com/shuto-okamoto/obsidian-notes

## 💡 トークンの保存

今後のために、生成したトークンを安全な場所に保存してください。

---

## 🚨 困ったときのサポート

各ステップのスクリーンショットを送ってください！
一緒に解決しましょう！