#!/bin/bash

# Obsidian Notes - 手動デプロイスクリプト（fastlane不要）
# Xcodeコマンドライン直接使用でApp Store Connect対応

# 色付け用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE} 🚀 Obsidian Notes Manual Deploy${NC}"
    echo -e "${PURPLE}    Xcode直接コマンドでApp Store Connect対応${NC}"
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
    
    # 必要な情報の確認
    echo "Bundle ID: ${DEVELOPER_APP_IDENTIFIER}"
    echo "App Name: ${APP_NAME}"
    echo "Scheme: ${SCHEME_NAME}"
}

# Xcodeプロジェクトをアーカイブ
archive_project() {
    print_step "Xcodeプロジェクトをアーカイブしています..."
    
    local archive_path="./build/Obsidian_Notes.xcarchive"
    local export_path="./build"
    
    # ディレクトリ作成
    mkdir -p build
    
    # アーカイブ実行
    xcodebuild archive \
        -scheme "Obsidian Notes" \
        -configuration Release \
        -destination 'generic/platform=iOS' \
        -archivePath "$archive_path" \
        DEVELOPMENT_TEAM="M925SB5N54" \
        CODE_SIGN_IDENTITY="iPhone Distribution" \
        CODE_SIGN_STYLE="Manual" || {
        print_error "アーカイブに失敗しました"
        return 1
    }
    
    print_success "アーカイブ完了: $archive_path"
}

# IPAファイル生成
export_ipa() {
    local archive_path="./build/Obsidian_Notes.xcarchive"
    local export_path="./build"
    local export_options_plist="./build/ExportOptions.plist"
    
    print_step "IPAファイルを生成しています..."
    
    # ExportOptions.plist作成
    cat > "$export_options_plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>M925SB5N54</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF
    
    # IPA生成
    xcodebuild -exportArchive \
        -archivePath "$archive_path" \
        -exportOptionsPlist "$export_options_plist" \
        -exportPath "$export_path" || {
        print_error "IPA生成に失敗しました"
        return 1
    }
    
    print_success "IPA生成完了: $export_path/Obsidian Notes.ipa"
}

# 次の手順表示
show_next_steps() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN} 🎉 手動デプロイ準備完了！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}生成されたファイル:${NC}"
    echo "📦 アーカイブ: ./build/Obsidian_Notes.xcarchive"
    echo "📱 IPAファイル: ./build/Obsidian Notes.ipa"
    echo ""
    echo -e "${BLUE}次のステップ (手動):${NC}"
    echo ""
    echo "1️⃣  Xcode Organizer でアップロード"
    echo "   - Xcode → Window → Organizer"
    echo "   - Archives タブ"
    echo "   - Obsidian Notes → Distribute App"
    echo "   - App Store Connect → Upload"
    echo ""
    echo "2️⃣  または Application Loader 使用"
    echo "   - ./build/Obsidian Notes.ipa をドラッグ&ドロップ"
    echo ""
    echo "3️⃣  App Store Connect で確認"
    echo "   - https://appstoreconnect.apple.com"
    echo "   - TestFlight → ビルド確認"
    echo ""
    echo -e "${PURPLE}🚀 App Store Connect手動アップロード準備完了！${NC}"
}

# メイン処理
main() {
    print_header
    check_env
    archive_project
    export_ipa
    show_next_steps
}

# 実行
main "$@"