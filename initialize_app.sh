#!/bin/bash

# AppFlowMVP - Universal App Initialization Script
# memo-app (Obsidian Notes) 専用バージョン

# --- 色付け用 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# --- ヘッダー ---
print_header() {
    clear
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE} 🚀 AppFlowMVP - Obsidian Notes Launcher${NC}"
    echo -e "${PURPLE}    App Store Connectに自動ローンチ！${NC}"
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

# --- プロジェクト自動検出 ---
detect_project_info() {
    print_step "プロジェクト情報を自動検出しています..."
    
    # プロジェクトファイルを取得
    local xcodeproj=$(find . -name "*.xcodeproj" -not -path "*/Pods/*" | head -1)
    local xcworkspace=$(find . -name "*.xcworkspace" -not -path "*/Pods/*" | head -1)
    
    if [ -z "$xcodeproj" ]; then
        print_error "Xcodeプロジェクトが見つかりません。"
        exit 1
    fi
    
    # プロジェクト名を取得
    PROJECT_NAME=$(basename "$xcodeproj" .xcodeproj)
    SCHEME_NAME="$PROJECT_NAME"
    
    # ワークスペースの有無を確認
    if [ -n "$xcworkspace" ]; then
        WORKSPACE_FILE=$(basename "$xcworkspace")
        USE_WORKSPACE=true
    else
        PROJECT_FILE=$(basename "$xcodeproj")
        USE_WORKSPACE=false
    fi
    
    print_success "プロジェクト検出完了: $PROJECT_NAME"
    echo "  - Scheme: $SCHEME_NAME"
    echo "  - Workspace: ${WORKSPACE_FILE:-'なし'}"
    echo "  - Project: ${PROJECT_FILE:-'なし'}"
}

# --- Obsidian Notes専用設定 ---
setup_obsidian_config() {
    print_step "Obsidian Notes用の設定を生成しています..."
    
    # 必要なディレクトリ作成
    mkdir -p config
    mkdir -p fastlane/metadata/ja-JP
    mkdir -p fastlane/screenshots
    mkdir -p scripts
    
    # Bundle IDを推測または設定
    BUNDLE_ID="com.okamotohideto.obsidiannotes"
    
    # 設定ファイル作成
    cat > config/app_config.yml << EOF
# Obsidian Notes App Configuration
# 生成日: $(date)

app:
  name: "Obsidian Notes"
  bundle_id: "$BUNDLE_ID"
  scheme: "$SCHEME_NAME"
  workspace: "${WORKSPACE_FILE:-$PROJECT_FILE}"
  project: "${PROJECT_FILE:-$SCHEME_NAME.xcodeproj}"
  type: "swiftui"

developer:
  team_id: "YOUR_TEAM_ID"  # Apple Developer Team ID
  apple_id: "your-apple-id@example.com"  # Apple ID
  company_name: "Okamoto Hideto"

urls:
  website: "https://obsidian-notes-app.com"
  privacy_policy: "https://obsidian-notes-app.com/privacy"
  support: "https://obsidian-notes-app.com/support"
  terms_of_service: "https://obsidian-notes-app.com/terms"

repository:
  certificates_repo: "https://github.com/okamotohideto/obsidian-notes-certificates"

notifications:
  slack_webhook: ""  # オプション

app_store:
  primary_category: "PRODUCTIVITY"
  secondary_category: "UTILITIES"
  content_rating: "4+"

version:
  initial: "1.0.0"
  build_initial: "1"

# Obsidian Notes専用設定
obsidian:
  theme_colors:
    - "Purple"
    - "Blue" 
    - "Green"
    - "Orange"
  features:
    - "Beautiful dark theme"
    - "Crystal-inspired design"
    - "Fast note taking"
    - "Search functionality"
    - "Multiple themes"
EOF
    
    print_success "設定ファイルを作成しました"
}

# --- メタデータ作成 ---
create_metadata() {
    print_step "App Store用メタデータを作成しています..."
    
    # 日本語メタデータ
    cat > fastlane/metadata/ja-JP/name.txt << 'EOF'
Obsidian Notes
EOF
    
    cat > fastlane/metadata/ja-JP/subtitle.txt << 'EOF'
美しいメモアプリ
EOF
    
    cat > fastlane/metadata/ja-JP/keywords.txt << 'EOF'
メモ,ノート,エディタ,テキスト,執筆,アイデア,思考,整理,ダーク,テーマ
EOF
    
    cat > fastlane/metadata/ja-JP/description.txt << 'EOF'
## 美しく、使いやすいメモアプリ

Obsidian Notesは、Obsidianからインスパイアされた美しいデザインのメモアプリです。

### ✨ 主な機能

• **美しいダークテーマ**
  洗練されたダークインターフェースで目に優しく、集中してメモを取ることができます

• **クリスタルデザイン**
  Obsidianの特徴的なクリスタルアイコンを採用し、エレガントなユーザー体験を提供

• **高速検索**
  瞬時にメモを検索・フィルタリングして、必要な情報をすぐに見つけられます

• **複数テーマ**
  パープル、ブルー、グリーン、オレンジから選べるアクセントカラー

• **シンプル操作**
  直感的なインターフェースで、思考を妨げることなくメモを記録

### 🎯 こんな方におすすめ

• きれいなメモアプリを探している方
• ダークテーマが好きな方
• 素早くアイデアを記録したい方
• シンプルながら美しいアプリを求める方

思考を美しく整理し、アイデアを輝かせましょう。今すぐダウンロードして、新しいメモ体験を始めてください！
EOF
    
    cat > fastlane/metadata/ja-JP/promotional_text.txt << 'EOF'
美しいデザインと直感的な操作性。Obsidianインスパイアのエレガントなメモアプリで、あなたの思考を輝かせます。
EOF
    
    # URL設定
    echo "https://obsidian-notes-app.com" > fastlane/metadata/ja-JP/marketing_url.txt
    echo "https://obsidian-notes-app.com/privacy" > fastlane/metadata/ja-JP/privacy_url.txt
    echo "https://obsidian-notes-app.com/support" > fastlane/metadata/ja-JP/support_url.txt
    
    print_success "メタデータを作成しました"
}

# --- 必要なスクリプトのコピー ---
copy_appflow_scripts() {
    print_step "AppFlowMVPスクリプトをコピーしています..."
    
    APPFLOW_DIR="/Users/okamotohideto/Documents/AppFlowMVP"
    
    # スクリプトをコピー
    cp -f "$APPFLOW_DIR/setup_enhanced.sh" ./
    cp -f "$APPFLOW_DIR/build_enhanced.sh" ./
    cp -f "$APPFLOW_DIR/deploy.sh" ./
    cp -f "$APPFLOW_DIR/setup_metadata.sh" ./
    cp -f "$APPFLOW_DIR/generate_ui_tests.sh" ./
    
    # 実行権限を付与
    chmod +x *.sh
    
    # Gemfile作成
    cat > Gemfile << 'EOF'
source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
EOF
    
    print_success "AppFlowMVPスクリプトをコピーしました"
}

# --- 環境変数ファイル作成 ---
create_env_file() {
    print_step "環境変数ファイルを作成しています..."
    
    cat > .env << EOF
# Fastlane環境変数 - Obsidian Notes
# これらの値を実際の認証情報に変更してください

DEVELOPER_APP_ID=$BUNDLE_ID
DEVELOPER_APP_IDENTIFIER=$BUNDLE_ID
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=your-app-specific-password
FASTLANE_SESSION=your-fastlane-session
MATCH_PASSWORD=your-match-password
SLACK_URL=

# Obsidian Notes固有の設定
APP_NAME="Obsidian Notes"
SCHEME_NAME="$SCHEME_NAME"
EOF
    
    print_success ".envファイルを作成しました"
}

# --- 次のステップ表示 ---
show_next_steps() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN} 🎉 Obsidian Notes初期化完了！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}次のステップ（App Store Connectローンチまで）:${NC}"
    echo ""
    echo "1️⃣  設定情報の編集"
    echo "   ${YELLOW}config/app_config.yml${NC} - Team IDとApple IDを設定"
    echo "   ${YELLOW}.env${NC} - App-Specific Passwordを設定"
    echo ""
    echo "2️⃣  証明書セットアップ"
    echo "   ${YELLOW}./setup_enhanced.sh${NC}"
    echo ""
    echo "3️⃣  アプリビルド"
    echo "   ${YELLOW}./build_enhanced.sh${NC}"
    echo ""
    echo "4️⃣  TestFlightアップロード"
    echo "   ${YELLOW}./deploy.sh beta${NC}"
    echo ""
    echo "5️⃣  App Storeリリース"
    echo "   ${YELLOW}./deploy.sh release${NC}"
    echo ""
    echo -e "${PURPLE}🚀 準備完了！あとは設定を編集してローンチするだけです！${NC}"
    echo ""
    echo -e "${YELLOW}重要: 以下の設定が必要です:${NC}"
    echo "• Apple Developer Team ID"
    echo "• App-Specific Password (https://appleid.apple.com で生成)"
    echo "• 証明書管理用のGitHubプライベートリポジトリ"
}

# --- メイン処理 ---
main() {
    print_header
    
    # プロジェクト検出
    detect_project_info
    
    # Obsidian Notes専用設定
    setup_obsidian_config
    
    # メタデータ作成
    create_metadata
    
    # AppFlowMVPスクリプトコピー
    copy_appflow_scripts
    
    # 環境変数ファイル作成
    create_env_file
    
    # 次のステップ表示
    show_next_steps
}

# 実行
main