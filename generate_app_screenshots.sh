#!/bin/bash

# Obsidian Notes - App Store用スクリーンショット生成スクリプト

# 色付け用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE} 📱 Obsidian Notes Screenshot Generator${NC}"
    echo -e "${PURPLE}    App Store Connect用スクリーンショット生成${NC}"
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

# スクリーンショット出力ディレクトリを作成
create_screenshot_dirs() {
    print_step "スクリーンショット用ディレクトリを作成しています..."
    
    mkdir -p fastlane/screenshots/ja
    mkdir -p fastlane/screenshots/raw
    
    print_success "ディレクトリ作成完了"
}

# シミュレーターでアプリを起動してスクリーンショット撮影
take_screenshots() {
    print_step "シミュレーターでアプリを起動してスクリーンショットを撮影しています..."
    
    # iPhone 16 Pro Max でアプリを起動
    DEVICE_ID="8E3A05BD-530E-470A-8012-62E4D350AEB3"
    
    print_step "シミュレーターを起動しています..."
    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
    
    print_step "アプリをビルド&インストールしています..."
    xcodebuild -scheme "Obsidian Notes" \
               -destination "platform=iOS Simulator,id=$DEVICE_ID" \
               -configuration Debug \
               build install > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "アプリのビルド&インストール完了"
    else
        print_error "アプリのビルド&インストールに失敗しました"
        return 1
    fi
    
    # アプリを起動
    print_step "アプリを起動しています..."
    xcrun simctl launch "$DEVICE_ID" "com.obsidian.notes.Obsidian-Notes"
    
    # 少し待機
    sleep 3
    
    # スクリーンショットを撮影
    print_step "スクリーンショットを撮影しています..."
    xcrun simctl io "$DEVICE_ID" screenshot "fastlane/screenshots/raw/01_MainScreen.png"
    
    print_success "スクリーンショット撮影完了"
}

# App Store用のデザインされたスクリーンショットを作成
create_designed_screenshots() {
    print_step "App Store用のデザインされたスクリーンショットを作成しています..."
    
    # Python/PIL または ImageMagick を使ってスクリーンショットにテキストオーバーレイを追加
    # ここでは簡単なコピーとして実装
    cp "fastlane/screenshots/raw/01_MainScreen.png" "fastlane/screenshots/ja/01_MainScreen.png"
    
    print_success "デザインされたスクリーンショット作成完了"
}

# メタデータの最終確認
check_metadata() {
    print_step "App Store用メタデータを確認しています..."
    
    if [ -f "fastlane/metadata/ja-JP/description.txt" ]; then
        print_success "日本語説明文: ✓"
    else
        print_error "日本語説明文が見つかりません"
    fi
    
    if [ -f "fastlane/metadata/ja-JP/keywords.txt" ]; then
        print_success "キーワード: ✓"
    else
        print_error "キーワードが見つかりません"
    fi
}

# 次のステップを表示
show_next_steps() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN} 🎉 スクリーンショット生成完了！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}次のステップ:${NC}"
    echo ""
    echo "1️⃣  スクリーンショットを確認"
    echo "   ${YELLOW}fastlane/screenshots/ja/${NC} フォルダを確認"
    echo ""
    echo "2️⃣  必要に応じてスクリーンショットを編集"
    echo "   App Store Connect用にテキストやバッジを追加"
    echo ""
    echo "3️⃣  App Store Connectに手動アップロード、または"
    echo "   ${YELLOW}./deploy.sh beta${NC} でTestFlightに自動アップロード"
    echo ""
    echo -e "${PURPLE}🚀 準備完了！App Store Connectでアプリを公開できます！${NC}"
}

# メイン処理
main() {
    print_header
    
    create_screenshot_dirs
    take_screenshots
    create_designed_screenshots
    check_metadata
    show_next_steps
}

# 実行
main