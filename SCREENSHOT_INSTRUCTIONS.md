# 📱 App Store用スクリーンショット作成手順

## 🎯 必要なスクリーンショット

### iPhone用 (6.7インチ - iPhone 15 Pro Max)
- **サイズ**: 1290 x 2796 px
- **必要枚数**: 3-10枚

### iPad用 (12.9インチ - iPad Pro)
- **サイズ**: 2048 x 2732 px  
- **必要枚数**: 3-10枚

## 📱 手動スクリーンショット手順

### 1. iPhoneシミュレーター
```bash
# iPhone 15 Pro Maxを起動
xcrun simctl boot "iPhone 15 Pro Max"
open -a Simulator
```

### 2. アプリをインストールして起動
- アプリをビルドしてシミュレーターにインストール
- Obsidian Notesアプリを起動
- 主要画面のスクリーンショットを撮影

### 3. スクリーンショット撮影
- **Command + S** でスクリーンショット保存
- または Simulator メニュー → Device → Screenshot

### 4. 推奨スクリーンショット内容
1. **メイン画面** - ノート一覧
2. **ノート作成画面** - 新規メモ作成
3. **テーマ選択画面** - カラーテーマ
4. **検索画面** - 検索機能
5. **ダークモード** - ダークテーマ表示

## 🎨 App Store Connect アップロード

1. App Store Connect → アプリ → Obsidian Notes
2. App Store → スクリーンショット
3. iPhone 6.7" セクションにドラッグ&ドロップ
4. iPad Pro 12.9" セクションにドラッグ&ドロップ

## 📁 保存場所
- `fastlane/screenshots/ja/` - 日本語用
- `fastlane/screenshots/en-US/` - 英語用

## ✅ 確認項目
- [ ] iPhone用スクリーンショット (3枚以上)
- [ ] iPad用スクリーンショット (3枚以上)  
- [ ] アプリの主要機能が分かる内容
- [ ] 画質が良好
- [ ] ファイルサイズが適切