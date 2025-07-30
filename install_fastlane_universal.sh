#!/bin/bash

# AppFlowMVP Universal - Fastlane完全自動インストール
# 汎用的にどんなアプリでも使えるFastlane環境構築

# 色付け用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE} 🚀 AppFlowMVP Universal Fastlane Installer${NC}"
    echo -e "${PURPLE}    汎用的iOS自動デプロイ環境完全構築${NC}"
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

# Ruby環境確認・設定
setup_ruby() {
    print_step "Ruby環境を確認・設定しています..."
    
    if command -v ruby >/dev/null 2>&1; then
        ruby_version=$(ruby -v)
        print_success "Ruby環境確認: $ruby_version"
    else
        print_error "Ruby環境が見つかりません"
        return 1
    fi
    
    # Gem環境確認
    if command -v gem >/dev/null 2>&1; then
        print_success "Gem環境確認済み"
    else
        print_error "Gem環境が見つかりません"
        return 1
    fi
}

# Fastlane複数方法でインストール
install_fastlane_multiple() {
    print_step "Fastlane複数方法インストール開始..."
    
    # 方法1: User installでGemインストール
    print_step "方法1: User Gem Install..."
    if gem install fastlane --user-install --no-document 2>/dev/null; then
        print_success "User Gem Install成功"
        
        # PATHに追加
        if [[ -d "$HOME/.gem/ruby" ]]; then
            GEM_PATH=$(find "$HOME/.gem/ruby" -name "bin" -type d | head -1)
            if [[ -n "$GEM_PATH" ]]; then
                export PATH="$GEM_PATH:$PATH"
                echo "export PATH=\"$GEM_PATH:\$PATH\"" >> ~/.zshrc
                echo "export PATH=\"$GEM_PATH:\$PATH\"" >> ~/.bash_profile
                print_success "Fastlane PATH設定完了"
            fi
        fi
    else
        print_error "User Gem Install失敗"
    fi
    
    # 方法2: Bundlerでインストール
    print_step "方法2: Bundler Install..."
    if gem install bundler --user-install --no-document 2>/dev/null; then
        cat > Gemfile << 'EOF'
source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
EOF
        
        if bundle install --path vendor/bundle 2>/dev/null; then
            print_success "Bundler Install成功"
        else
            print_error "Bundler Install失敗"
        fi
    fi
    
    # 方法3: Homebrewでインストール
    print_step "方法3: Homebrew Install..."
    if command -v brew >/dev/null 2>&1; then
        if brew install fastlane 2>/dev/null; then
            print_success "Homebrew Install成功"
        else
            print_error "Homebrew Install失敗"
        fi
    else
        print_step "Homebrewをインストール中..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
            print_error "Homebrewインストール失敗"
        }
        
        # PATH設定
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
            echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
        fi
        
        # 再試行
        if command -v brew >/dev/null 2>&1; then
            brew install fastlane
            print_success "Homebrew経由Fastlaneインストール成功"
        fi
    fi
}

# Fastlane認証テスト
test_fastlane_auth() {
    print_step "Fastlane認証テストを実行しています..."
    
    # 環境変数読み込み
    if [[ -f ".env" ]]; then
        source .env
        print_success ".env読み込み完了"
    else
        print_error ".envファイルが見つかりません"
        return 1
    fi
    
    # Fastlaneコマンド確認
    local fastlane_cmd=""
    if command -v fastlane >/dev/null 2>&1; then
        fastlane_cmd="fastlane"
    elif [[ -f "vendor/bundle/bin/fastlane" ]]; then
        fastlane_cmd="bundle exec fastlane"
    else
        print_error "Fastlaneコマンドが見つかりません"
        return 1
    fi
    
    print_success "Fastlaneコマンド確認: $fastlane_cmd"
    
    # Apple ID認証テスト
    print_step "Apple ID認証テスト実行中..."
    echo "Apple ID: $FASTLANE_APPLE_ID"
    echo "Password: ${FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD:0:4}****"
    
    # 簡易認証チェック
    $fastlane_cmd run app_store_connect_api_key || {
        print_error "認証テスト失敗 - App Store Connect接続を確認してください"
        return 1
    }
    
    print_success "Apple ID認証テスト成功"
}

# 汎用設定ファイル作成
create_universal_config() {
    print_step "汎用設定ファイルを作成しています..."
    
    # 汎用Fastfile作成
    mkdir -p fastlane
    cat > fastlane/Fastfile << 'EOF'
# AppFlowMVP Universal Fastfile
# 汎用的にどんなiOSアプリでも使える自動デプロイ設定

default_platform(:ios)

platform :ios do
  desc "🚀 Universal Beta Deploy - TestFlight"
  lane :beta do
    # 環境変数確認
    ensure_env_vars(
      env_vars: ['FASTLANE_APPLE_ID', 'DEVELOPER_APP_IDENTIFIER']
    )

    # 証明書とプロビジョニングプロファイル
    match(type: "appstore", readonly: true)

    # ビルド
    build_app(
      scheme: ENV['SCHEME_NAME'] || "Runner",
      export_method: "app-store"
    )

    # TestFlightアップロード
    upload_to_testflight(
      skip_waiting_for_build_processing: true
    )

    puts "🎉 TestFlightアップロード完了！"
  end

  desc "🌟 Universal Release Deploy - App Store"
  lane :release do
    # メタデータアップロード
    upload_to_app_store(
      submit_for_review: false,
      automatic_release: false,
      force: true
    )

    puts "🎉 App Store準備完了！"
  end
end
EOF

    # 汎用Appfile作成
    cat > fastlane/Appfile << 'EOF'
# AppFlowMVP Universal Appfile
app_identifier(ENV['DEVELOPER_APP_IDENTIFIER'])
apple_id(ENV['FASTLANE_APPLE_ID'])
team_id(ENV['DEVELOPER_TEAM_ID'] || "YOUR_TEAM_ID")
EOF

    print_success "汎用設定ファイル作成完了"
}

# 次のステップ表示
show_next_steps() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN} 🎉 AppFlowMVP Universal Fastlane準備完了！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}使用方法（どんなiOSアプリでも）:${NC}"
    echo ""
    echo "1️⃣  新プロジェクトに適用"
    echo "   ${YELLOW}cp -R /path/to/AppFlowMVP/* /your/project/${NC}"
    echo ""
    echo "2️⃣  環境変数設定"
    echo "   ${YELLOW}nano .env${NC} でApple ID設定"
    echo ""
    echo "3️⃣  自動デプロイ実行"
    echo "   ${YELLOW}fastlane beta${NC} または ${YELLOW}bundle exec fastlane beta${NC}"
    echo ""
    echo -e "${PURPLE}🚀 汎用的iOS自動デプロイフレームワーク完成！${NC}"
    echo -e "${PURPLE}   どんなアプリでも3分でTestFlightデプロイ可能！${NC}"
}

# メイン処理
main() {
    print_header
    setup_ruby
    install_fastlane_multiple
    create_universal_config
    test_fastlane_auth
    show_next_steps
}

# 実行
main "$@"