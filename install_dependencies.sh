#!/bin/bash

# AppFlowMVP - 依存関係自動インストールスクリプト
# 汎用的にどの環境でも動作するように改善

# 色付け用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE} 🔧 AppFlowMVP Dependencies Installer${NC}"
    echo -e "${PURPLE}    汎用iOS自動デプロイ環境セットアップ${NC}"
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

# Homebrewインストール（macOSの場合）
install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        print_success "Homebrew already installed"
        return 0
    fi

    print_step "Installing Homebrew..."
    
    # Homebrewインストールスクリプト実行
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
        print_error "Homebrew installation failed"
        return 1
    }
    
    # PATHを設定
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
        echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
    elif [[ -f "/usr/local/bin/brew" ]]; then
        export PATH="/usr/local/bin:$PATH"
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
    fi
    
    print_success "Homebrew installed successfully"
}

# Fastlane インストール
install_fastlane() {
    if command -v fastlane >/dev/null 2>&1; then
        print_success "Fastlane already installed"
        return 0
    fi

    print_step "Installing Fastlane..."
    
    # Gemを使ってインストール
    if command -v gem >/dev/null 2>&1; then
        sudo gem install fastlane -NV || {
            print_error "Fastlane installation failed via gem"
            
            # Homebrewでの代替インストール
            if command -v brew >/dev/null 2>&1; then
                print_step "Trying installation via Homebrew..."
                brew install fastlane || {
                    print_error "Fastlane installation failed"
                    return 1
                }
            else
                return 1
            fi
        }
    else
        print_error "Ruby/Gem not found. Please install Ruby first."
        return 1
    fi
    
    print_success "Fastlane installed successfully"
}

# yq（YAML parser）インストール
install_yq() {
    if command -v yq >/dev/null 2>&1; then
        print_success "yq already installed"
        return 0
    fi

    print_step "Installing yq (YAML processor)..."
    
    if command -v brew >/dev/null 2>&1; then
        brew install yq || {
            print_error "yq installation failed"
            return 1
        }
    else
        print_error "Homebrew not found. Cannot install yq."
        return 1
    fi
    
    print_success "yq installed successfully"
}

# CocoaPods インストール
install_cocoapods() {
    if command -v pod >/dev/null 2>&1; then
        print_success "CocoaPods already installed"
        return 0
    fi

    print_step "Installing CocoaPods..."
    
    if command -v gem >/dev/null 2>&1; then
        sudo gem install cocoapods -NV || {
            print_error "CocoaPods installation failed"
            return 1
        }
        
        # repo setup
        pod setup --silent || {
            print_error "CocoaPods setup failed"
            return 1
        }
    else
        print_error "Ruby/Gem not found. Please install Ruby first."
        return 1
    fi
    
    print_success "CocoaPods installed successfully"
}

# Xcode Command Line Tools確認
check_xcode_tools() {
    print_step "Checking Xcode Command Line Tools..."
    
    if xcode-select -p >/dev/null 2>&1; then
        print_success "Xcode Command Line Tools already installed"
        return 0
    fi
    
    print_step "Installing Xcode Command Line Tools..."
    xcode-select --install
    
    print_step "Please complete Xcode Command Line Tools installation and re-run this script"
    exit 1
}

# Ruby version確認
check_ruby() {
    print_step "Checking Ruby installation..."
    
    if command -v ruby >/dev/null 2>&1; then
        ruby_version=$(ruby -v)
        print_success "Ruby found: $ruby_version"
        return 0
    else
        print_error "Ruby not found. Please install Ruby first."
        
        # rbenv経由でのRubyインストール提案
        if command -v brew >/dev/null 2>&1; then
            print_step "Installing Ruby via rbenv..."
            brew install rbenv ruby-build
            rbenv install 3.0.0
            rbenv global 3.0.0
            echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
            echo 'eval "$(rbenv init -)"' >> ~/.zshrc
            
            # 新しいシェルで再実行を促す
            print_step "Ruby installed. Please restart terminal and re-run this script."
            exit 1
        else
            return 1
        fi
    fi
}

# 環境チェック
check_environment() {
    print_step "Checking development environment..."
    
    # macOS確認
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi
    
    print_success "macOS detected"
}

# Fastlane plugins インストール
install_fastlane_plugins() {
    print_step "Installing essential Fastlane plugins..."
    
    if command -v fastlane >/dev/null 2>&1; then
        # よく使われるプラグインをインストール
        fastlane add_plugin increment_build_number 2>/dev/null || true
        fastlane add_plugin badge 2>/dev/null || true
        fastlane add_plugin versioning 2>/dev/null || true
        
        print_success "Fastlane plugins installed"
    else
        print_error "Fastlane not found. Cannot install plugins."
    fi
}

# 設定ファイルテンプレート作成
create_templates() {
    print_step "Creating configuration templates..."
    
    # Gemfile作成
    if [[ ! -f "Gemfile" ]]; then
        cat > Gemfile << 'EOF'
source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
EOF
        print_success "Gemfile created"
    fi
    
    # .gitignore更新
    if [[ -f ".gitignore" ]]; then
        # AppFlowMVP関連の除外設定を追加
        grep -q "# AppFlowMVP" .gitignore || {
            cat >> .gitignore << 'EOF'

# AppFlowMVP
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots
fastlane/test_output
.env.default
.env.local
build/
*.ipa
*.dSYM.zip
EOF
            print_success ".gitignore updated"
        }
    fi
}

# メイン処理
main() {
    print_header
    
    check_environment
    check_xcode_tools
    install_homebrew
    check_ruby
    install_fastlane
    install_yq
    install_cocoapods
    install_fastlane_plugins
    create_templates
    
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN} 🎉 AppFlowMVP環境セットアップ完了！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}インストール完了:${NC}"
    echo "✅ Homebrew"
    echo "✅ Fastlane"
    echo "✅ yq (YAML processor)"
    echo "✅ CocoaPods"
    echo "✅ Fastlane Plugins"
    echo ""
    echo -e "${PURPLE}次のステップ:${NC}"
    echo "1. ${YELLOW}./initialize_app.sh${NC} - プロジェクト初期化"
    echo "2. ${YELLOW}./setup_enhanced.sh${NC} - 証明書セットアップ"
    echo "3. ${YELLOW}./deploy.sh beta${NC} - TestFlightデプロイ"
    echo ""
    echo -e "${PURPLE}🚀 任意のiOSプロジェクトでApp Store Connect自動デプロイ準備完了！${NC}"
}

# 実行
main "$@"