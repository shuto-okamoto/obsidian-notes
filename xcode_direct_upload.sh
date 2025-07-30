#!/bin/bash

# Obsidian Notes - Xcode直接アップロードスクリプト
# Fastlane不要でApp Store Connect自動アップロード

# 色付け用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE} 🚀 Obsidian Notes Direct Upload${NC}"
    echo -e "${PURPLE}    Xcode直接コマンドでApp Store Connect自動アップロード${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 環境変数確認
check_env() {
    print_step "環境変数を確認しています..."
    
    if [[ -f ".env" ]]; then
        source .env
        print_success ".env ファイル読み込み完了"
    else
        print_error ".env ファイルが見つかりません"
        return 1
    fi
    
    echo "Bundle ID: ${DEVELOPER_APP_IDENTIFIER}"
    echo "Apple ID: ${FASTLANE_APPLE_ID}"
    echo "App Name: ${APP_NAME}"
}

# Xcodeプロジェクトをアーカイブ（App Store用）
archive_for_appstore() {
    print_step "App Store用アーカイブを作成しています..."
    
    local archive_path="./build/Obsidian_Notes_AppStore.xcarchive"
    
    # ディレクトリ作成
    mkdir -p build
    
    # App Store用アーカイブ（Automatic Code Signing）
    xcodebuild archive \
        -scheme "Obsidian Notes" \
        -configuration Release \
        -destination 'generic/platform=iOS' \
        -archivePath "$archive_path" \
        CODE_SIGN_STYLE="Automatic" \
        DEVELOPMENT_TEAM="M925SB5N54" || {
        print_error "アーカイブに失敗しました"
        return 1
    }
    
    print_success "App Store用アーカイブ完了: $archive_path"
}

# App Store Connect自動アップロード
upload_to_appstore() {
    local archive_path="./build/Obsidian_Notes_AppStore.xcarchive"
    
    print_step "App Store Connectに自動アップロードしています..."
    
    # App Store Connect自動アップロード
    xcodebuild -exportArchive \
        -archivePath "$archive_path" \
        -exportOptionsPlist <(cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>destination</key>
    <string>upload</string>
    <key>teamID</key>
    <string>M925SB5N54</string>
</dict>
</plist>
EOF
) \
        -exportPath "./build/upload" || {
        print_error "App Store Connectアップロードに失敗しました"
        return 1
    }
    
    print_success "App Store Connect自動アップロード完了！"
}

# TestFlight確認URL表示
show_testflight_info() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN} 🎉 TestFlight自動アップロード完了！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}次のステップ:${NC}"
    echo ""
    echo "1️⃣  App Store Connectで確認"
    echo "   ${YELLOW}https://appstoreconnect.apple.com${NC}"
    echo "   → マイApp → Obsidian Notes → TestFlight"
    echo ""
    echo "2️⃣  ビルド処理完了を待機（5-10分）"
    echo "   Apple側でビルド処理が完了するまで待機"
    echo ""
    echo "3️⃣  TestFlight配布開始"
    echo "   ビルド処理完了後、テスターに配布可能"
    echo ""
    echo -e "${PURPLE}🚀 Obsidian Notes TestFlight配布準備完了！${NC}"
    echo -e "${PURPLE}   App Store Connect: https://appstoreconnect.apple.com${NC}"
}

# メイン処理
main() {
    print_header
    check_env
    archive_for_appstore
    upload_to_appstore
    show_testflight_info
}

# 実行
main "$@"