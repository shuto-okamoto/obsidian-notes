#!/bin/bash

# AppFlowMVP Enhanced Setup Script
# REAL PASTの自動化機能を統合した強化版セットアップスクリプト

# --- 色付け用 ---
Color_Off='\033[0m'
BRed='\033[1;31m'
BGreen='\033[1;32m'
BYellow='\033[1;33m'
BBlue='\033[1;34m'

# --- ヘッダー表示 ---
echo "${BBlue}================================================${Color_Off}"
echo "${BBlue} AppFlowMVP Enhanced Setup - v2.0${Color_Off}"
echo "${BBlue} REAL PAST自動化機能統合版${Color_Off}"
echo "${BBlue}================================================${Color_Off}"
echo ""

# --- 設定ファイルの確認 ---
echo "${BYellow}Step 0: 設定ファイルを確認します...${Color_Off}"

CONFIG_FILE="config/app_config.yml"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "${BYellow}設定ファイルが見つかりません。テンプレートを作成します...${Color_Off}"
    
    # configディレクトリ作成
    mkdir -p config
    
    # テンプレート作成
    cat > "$CONFIG_FILE" << 'EOF'
# App Configuration
# このファイルを編集して、アプリの設定を記入してください

app:
  name: "Your App Name"
  bundle_id: "com.yourcompany.yourapp"
  scheme: "Runner"
  workspace: "Runner.xcworkspace"
  project: "Runner.xcodeproj"

developer:
  team_id: "YOUR_TEAM_ID"
  apple_id: "your-apple-id@example.com"
  company_name: "Your Company"

urls:
  website: "https://your-website.com"
  privacy_policy: "https://your-website.com/privacy"
  support: "https://your-website.com/support"
  terms_of_service: "https://your-website.com/terms"

repository:
  certificates_repo: "https://github.com/yourcompany/certificates"

notifications:
  slack_webhook: ""  # オプション

app_store:
  primary_category: "PRODUCTIVITY"
  secondary_category: ""
  content_rating: "4+"

version:
  initial: "1.0.0"
  build_initial: "1"
EOF

    echo "${BGreen}設定ファイルのテンプレートを作成しました: $CONFIG_FILE${Color_Off}"
    echo "${BRed}重要: $CONFIG_FILE を編集してから再度このスクリプトを実行してください。${Color_Off}"
    exit 0
fi

# --- 必要なツールのインストール確認 ---
echo "${BYellow}Step 1: 必要なツールを確認・インストールします...${Color_Off}"

# Homebrew
if ! command -v brew &> /dev/null; then
    echo "${BYellow}Homebrewがインストールされていません。インストールします...${Color_Off}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Fastlane
if ! command -v fastlane &> /dev/null; then
    echo "${BYellow}Fastlaneがインストールされていません。インストールします...${Color_Off}"
    brew install fastlane
fi

# Ruby (for configuration scripts)
if ! command -v ruby &> /dev/null; then
    echo "${BRed}Rubyがインストールされていません。macOSには標準でインストールされているはずです。${Color_Off}"
    exit 1
fi

# yq (YAML parser)
if ! command -v yq &> /dev/null; then
    echo "${BYellow}yqがインストールされていません。インストールします...${Color_Off}"
    brew install yq
fi

echo "${BGreen}必要なツールの準備OK。${Color_Off}"

# --- 設定値の読み込み ---
echo "${BYellow}Step 2: 設定ファイルから値を読み込みます...${Color_Off}"

BUNDLE_ID=$(yq eval '.app.bundle_id' $CONFIG_FILE)
TEAM_ID=$(yq eval '.developer.team_id' $CONFIG_FILE)
APPLE_ID=$(yq eval '.developer.apple_id' $CONFIG_FILE)
CERT_REPO=$(yq eval '.repository.certificates_repo' $CONFIG_FILE)

if [ "$BUNDLE_ID" == "com.yourcompany.yourapp" ]; then
    echo "${BRed}エラー: 設定ファイルがデフォルト値のままです。${Color_Off}"
    echo "config/app_config.yml を編集してください。"
    exit 1
fi

# --- Fastlane初期化 ---
echo "${BYellow}Step 3: Fastlaneを初期化します...${Color_Off}"

if [ ! -d "fastlane" ]; then
    mkdir -p fastlane
fi

# Appfile作成
cat > "fastlane/Appfile" << EOF
app_identifier("$BUNDLE_ID")
apple_id("$APPLE_ID")
team_id("$TEAM_ID")
EOF

# --- Matchfile作成 ---
if [ ! -f "fastlane/Matchfile" ]; then
    echo "${BYellow}Matchfileを作成します...${Color_Off}"
    
    cat > "fastlane/Matchfile" << EOF
git_url("$CERT_REPO")
storage_mode("git")
type("development")
type("appstore")
app_identifier(["$BUNDLE_ID"])
username("$APPLE_ID")
EOF
fi

# --- Gemfile作成 ---
if [ ! -f "Gemfile" ]; then
    echo "${BYellow}Gemfileを作成します...${Color_Off}"
    
    cat > "Gemfile" << 'EOF'
source "https://rubygems.org"

gem "fastlane"
gem "cocoapods"
EOF

    echo "${BYellow}依存関係をインストールします...${Color_Off}"
    bundle install
fi

# --- 証明書セットアップ ---
echo "${BYellow}Step 4: 証明書をセットアップします...${Color_Off}"

# 証明書リポジトリの存在確認
echo "証明書管理用のGitリポジトリ: $CERT_REPO"
read -p "このリポジトリは作成済みですか？ (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "${BRed}証明書管理用のプライベートGitリポジトリを作成してください。${Color_Off}"
    echo "1. GitHubで新しいプライベートリポジトリを作成"
    echo "2. config/app_config.yml の certificates_repo を更新"
    echo "3. このスクリプトを再実行"
    exit 1
fi

# Match実行
echo "${BYellow}開発用証明書を準備します...${Color_Off}"
bundle exec fastlane match development

echo "${BYellow}App Store用証明書を準備します...${Color_Off}"
bundle exec fastlane match appstore

# --- 環境変数ファイル作成 ---
echo "${BYellow}Step 5: 環境変数ファイルを作成します...${Color_Off}"

if [ ! -f ".env" ]; then
    cat > ".env" << EOF
# Fastlane環境変数
# これらの値を設定してください

DEVELOPER_APP_ID=$BUNDLE_ID
DEVELOPER_APP_IDENTIFIER=$BUNDLE_ID
FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD=your-app-specific-password
FASTLANE_SESSION=your-fastlane-session
MATCH_PASSWORD=your-match-password
SLACK_URL=
EOF

    echo "${BGreen}.envファイルを作成しました。${Color_Off}"
    echo "${BRed}重要: .envファイルに必要な認証情報を設定してください。${Color_Off}"
fi

# --- 追加スクリプトのインストール ---
echo "${BYellow}Step 6: 追加の自動化スクリプトをインストールします...${Color_Off}"

# scripts ディレクトリ作成
mkdir -p scripts

# 設定適用スクリプト
if [ ! -f "scripts/apply_config.rb" ]; then
    curl -sL https://raw.githubusercontent.com/yourusername/appflow-scripts/main/apply_config.rb -o scripts/apply_config.rb
    chmod +x scripts/apply_config.rb
fi

# スクリーンショット生成準備
mkdir -p fastlane/screenshots
mkdir -p fastlane/metadata

echo ""
echo "${BGreen}🎉 セットアップが完了しました！${Color_Off}"
echo ""
echo "${BYellow}次のステップ:${Color_Off}"
echo "1. .env ファイルに認証情報を設定"
echo "2. ./build_enhanced.sh でビルド実行"
echo "3. ./deploy.sh でApp Storeにデプロイ"
echo ""
echo "${BBlue}ヒント: './deploy.sh help' でコマンドヘルプを表示${Color_Off}"