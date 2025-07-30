#!/bin/bash

# AppFlowMVP Enhanced Build Script
# 設定ファイルベースの自動ビルドスクリプト

# --- 色付け用 ---
Color_Off='\033[0m'
BRed='\033[1;31m'
BGreen='\033[1;32m'
BYellow='\033[1;33m'
BBlue='\033[1;34m'

# --- ヘッダー表示 ---
print_header() {
    echo "${BBlue}================================================${Color_Off}"
    echo "${BBlue} AppFlowMVP Enhanced Build${Color_Off}"
    echo "${BBlue}================================================${Color_Off}"
    echo ""
}

# --- エラーハンドリング ---
set -e
trap 'echo "${BRed}エラーが発生しました。ビルドを中止します。${Color_Off}"' ERR

print_header

# --- 設定ファイルの確認 ---
CONFIG_FILE="config/app_config.yml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "${BRed}エラー: 設定ファイルが見つかりません。${Color_Off}"
    echo "先に './setup_enhanced.sh' を実行してください。"
    exit 1
fi

# --- yqインストール確認 ---
if ! command -v yq &> /dev/null; then
    echo "${BYellow}yqをインストールします...${Color_Off}"
    brew install yq
fi

# --- 設定値の読み込み ---
echo "${BYellow}設定ファイルから値を読み込みます...${Color_Off}"

APP_NAME=$(yq eval '.app.name' $CONFIG_FILE)
BUNDLE_ID=$(yq eval '.app.bundle_id' $CONFIG_FILE)
SCHEME=$(yq eval '.app.scheme' $CONFIG_FILE)
WORKSPACE=$(yq eval '.app.workspace' $CONFIG_FILE)
PROJECT=$(yq eval '.app.project' $CONFIG_FILE)
TEAM_ID=$(yq eval '.developer.team_id' $CONFIG_FILE)

# ワークスペースが存在するか確認
USE_WORKSPACE=true
if [ ! -f "$WORKSPACE" ]; then
    if [ -f "$PROJECT" ]; then
        USE_WORKSPACE=false
        echo "${BYellow}ワークスペースが見つかりません。プロジェクトファイルを使用します。${Color_Off}"
    else
        echo "${BRed}エラー: ワークスペースもプロジェクトファイルも見つかりません。${Color_Off}"
        exit 1
    fi
fi

# --- ビルド設定 ---
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/${SCHEME}.xcarchive"
EXPORT_DIR="$BUILD_DIR/ipa"
EXPORT_OPTIONS_PLIST="$BUILD_DIR/ExportOptions.plist"
OUTPUT_IPA_NAME="${APP_NAME// /}.ipa"  # スペースを削除

# ディレクトリ作成
mkdir -p $BUILD_DIR
mkdir -p $EXPORT_DIR

# --- ExportOptions.plist生成 ---
echo "${BYellow}エクスポート設定を生成します...${Color_Off}"

cat > $EXPORT_OPTIONS_PLIST << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>$BUNDLE_ID</key>
        <string>match AppStore $BUNDLE_ID</string>
    </dict>
    <key>signingStyle</key>
    <string>manual</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF

# --- クリーンビルド ---
echo "${BYellow}DerivedDataをクリーンします...${Color_Off}"
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# --- ビルドコマンドの組み立て ---
BUILD_COMMAND="xcodebuild -scheme \"$SCHEME\""

if $USE_WORKSPACE; then
    BUILD_COMMAND+=" -workspace \"$WORKSPACE\""
else
    BUILD_COMMAND+=" -project \"$PROJECT\""
fi

# --- ビルド番号の更新 ---
echo "${BYellow}ビルド番号を更新します...${Color_Off}"

# 現在のビルド番号を取得
CURRENT_BUILD=$(xcodebuild -showBuildSettings -scheme "$SCHEME" | grep CURRENT_PROJECT_VERSION | tr -d 'CURRENT_PROJECT_VERSION = ' | xargs)
NEW_BUILD=$((CURRENT_BUILD + 1))

echo "現在のビルド番号: $CURRENT_BUILD"
echo "新しいビルド番号: $NEW_BUILD"

# Info.plistのパスを取得（複数のターゲットに対応）
INFO_PLIST_FILES=$(find . -name "Info.plist" -not -path "./build/*" -not -path "./Pods/*")

for plist in $INFO_PLIST_FILES; do
    if [ -f "$plist" ]; then
        /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$plist" 2>/dev/null || true
    fi
done

# --- アーカイブ ---
echo ""
echo "${BYellow}アーカイブを作成します...${Color_Off}"
echo "これには数分かかる場合があります。"

ARCHIVE_CMD="$BUILD_COMMAND -sdk iphoneos -configuration Release clean archive -archivePath \"$ARCHIVE_PATH\" DEVELOPMENT_TEAM=\"$TEAM_ID\""

echo "${BBlue}実行コマンド:${Color_Off}"
echo "$ARCHIVE_CMD"
echo ""

eval $ARCHIVE_CMD

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo "${BRed}アーカイブの作成に失敗しました。${Color_Off}"
    exit 1
fi

echo "${BGreen}アーカイブ作成成功！${Color_Off}"

# --- .ipa ファイルのエクスポート ---
echo ""
echo "${BYellow}.ipaファイルをエクスポートします...${Color_Off}"

EXPORT_CMD="xcodebuild -exportArchive -archivePath \"$ARCHIVE_PATH\" -exportPath \"$EXPORT_DIR\" -exportOptionsPlist \"$EXPORT_OPTIONS_PLIST\""

echo "${BBlue}実行コマンド:${Color_Off}"
echo "$EXPORT_CMD"
echo ""

eval $EXPORT_CMD

# 生成されたipaファイルを探す
IPA_FILE=$(find "$EXPORT_DIR" -name "*.ipa" | head -n 1)

if [ -z "$IPA_FILE" ]; then
    echo "${BRed}.ipaファイルが見つかりません。${Color_Off}"
    exit 1
fi

# リネーム
mv "$IPA_FILE" "$EXPORT_DIR/$OUTPUT_IPA_NAME"

# --- dSYMファイルのバックアップ ---
echo "${BYellow}dSYMファイルをバックアップします...${Color_Off}"

DSYM_DIR="$BUILD_DIR/dSYMs"
mkdir -p "$DSYM_DIR"

if [ -d "$ARCHIVE_PATH/dSYMs" ]; then
    cp -R "$ARCHIVE_PATH/dSYMs/" "$DSYM_DIR/"
    echo "${BGreen}dSYMファイルをバックアップしました。${Color_Off}"
fi

# --- ビルド情報の保存 ---
BUILD_INFO="$BUILD_DIR/build_info.json"
cat > "$BUILD_INFO" << EOF
{
  "app_name": "$APP_NAME",
  "bundle_id": "$BUNDLE_ID",
  "version": "$(yq eval '.version.initial' $CONFIG_FILE)",
  "build_number": "$NEW_BUILD",
  "build_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "ipa_path": "$EXPORT_DIR/$OUTPUT_IPA_NAME",
  "archive_path": "$ARCHIVE_PATH"
}
EOF

# --- 完了メッセージ ---
echo ""
echo "${BGreen}================================================${Color_Off}"
echo "${BGreen} 🎉 ビルドが正常に完了しました！${Color_Off}"
echo "${BGreen}================================================${Color_Off}"
echo ""
echo "${BYellow}ビルド情報:${Color_Off}"
echo "  アプリ名: $APP_NAME"
echo "  Bundle ID: $BUNDLE_ID"
echo "  ビルド番号: $NEW_BUILD"
echo "  IPAファイル: $EXPORT_DIR/$OUTPUT_IPA_NAME"
echo ""
echo "${BYellow}次のステップ:${Color_Off}"
echo "  1. ./deploy.sh beta     # TestFlightにアップロード"
echo "  2. ./deploy.sh release  # App Storeにリリース"
echo ""