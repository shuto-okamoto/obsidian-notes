#!/bin/bash

# AppFlowMVP Deployment Script
# App Store ConnectとTestFlightへの自動デプロイ

set -e

# --- 色付け用 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- 関数定義 ---
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE} AppFlowMVP Deployment${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# --- 設定確認 ---
check_config() {
    print_step "設定を確認しています..."
    
    if [ ! -f "config/app_config.yml" ]; then
        print_error "設定ファイルが見つかりません。"
        echo "先に './setup_enhanced.sh' を実行してください。"
        exit 1
    fi
    
    if [ ! -f ".env" ]; then
        print_error ".envファイルが見つかりません。"
        echo "先に './setup_enhanced.sh' を実行してください。"
        exit 1
    fi
    
    # .envファイルを読み込む
    export $(cat .env | grep -v '^#' | xargs)
    
    if [ -z "$FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" ]; then
        print_error "App-Specific Passwordが設定されていません。"
        echo ".envファイルにFASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORDを設定してください。"
        exit 1
    fi
    
    print_success "設定確認完了"
}

# --- Fastfile確認 ---
check_fastfile() {
    if [ ! -f "fastlane/Fastfile" ]; then
        print_step "Fastfileを作成します..."
        create_fastfile
    fi
}

# --- Fastfile作成 ---
create_fastfile() {
    # 設定値を読み込む
    BUNDLE_ID=$(yq eval '.app.bundle_id' config/app_config.yml)
    SCHEME=$(yq eval '.app.scheme' config/app_config.yml)
    WORKSPACE=$(yq eval '.app.workspace' config/app_config.yml)
    PROJECT=$(yq eval '.app.project' config/app_config.yml)
    
    cat > "fastlane/Fastfile" << EOF
# Fastfile - Auto-generated by AppFlowMVP

default_platform(:ios)

platform :ios do
  
  # Variables
  APP_IDENTIFIER = "$BUNDLE_ID"
  SCHEME = "$SCHEME"
  WORKSPACE = "$WORKSPACE"
  PROJECT = "$PROJECT"
  
  desc "Run tests"
  lane :test do
    run_tests(
      scheme: SCHEME,
      device: "iPhone 15 Pro"
    )
  end
  
  desc "Generate screenshots"
  lane :screenshots do
    capture_screenshots(
      scheme: SCHEME,
      devices: [
        "iPhone 15 Pro Max",
        "iPhone 15 Pro",
        "iPhone 13",
        "iPhone SE (3rd generation)",
        "iPad Pro (12.9-inch) (6th generation)"
      ],
      languages: ["ja-JP"],
      clear_previous_screenshots: true,
      override_status_bar: true
    )
  end
  
  desc "Upload to TestFlight"
  lane :beta do
    # 証明書取得
    match(type: "appstore")
    
    # IPAパスを取得
    ipa_path = "../build/ipa/*.ipa"
    
    # TestFlightへアップロード
    upload_to_testflight(
      ipa: ipa_path,
      skip_waiting_for_build_processing: false,
      changelog: "バグ修正と機能改善"
    )
    
    # Slack通知（設定されている場合）
    if ENV["SLACK_URL"] && !ENV["SLACK_URL"].empty?
      slack(
        message: "🚀 TestFlightへのアップロードが完了しました！",
        success: true
      )
    end
  end
  
  desc "Submit to App Store"
  lane :release do
    # 証明書取得
    match(type: "appstore")
    
    # メタデータとスクリーンショットをアップロード
    deliver(
      submit_for_review: true,
      automatic_release: true,
      force: true,
      skip_binary_upload: false,
      metadata_path: "./fastlane/metadata",
      screenshots_path: "./fastlane/screenshots",
      precheck_include_in_app_purchases: false
    )
    
    # Slack通知（設定されている場合）
    if ENV["SLACK_URL"] && !ENV["SLACK_URL"].empty?
      slack(
        message: "🎉 App Storeへの申請が完了しました！",
        success: true
      )
    end
  end
  
  desc "Update metadata only"
  lane :update_metadata do
    deliver(
      submit_for_review: false,
      skip_binary_upload: true,
      skip_screenshots: false,
      force: true,
      metadata_path: "./fastlane/metadata",
      screenshots_path: "./fastlane/screenshots"
    )
  end
  
  # エラーハンドリング
  error do |lane, exception|
    if ENV["SLACK_URL"] && !ENV["SLACK_URL"].empty?
      slack(
        message: "❌ Lane '#{lane}' でエラーが発生しました: #{exception.message}",
        success: false
      )
    end
  end
end
EOF
    
    print_success "Fastfileを作成しました"
}

# --- スクリーンショット生成 ---
generate_screenshots() {
    print_step "スクリーンショットを生成します..."
    
    # UIテストが存在するか確認
    if [ ! -d "*UITests" ]; then
        print_error "UIテストが見つかりません。"
        echo "スクリーンショット生成にはUIテストが必要です。"
        return 1
    fi
    
    bundle exec fastlane screenshots
    print_success "スクリーンショット生成完了"
}

# --- TestFlightデプロイ ---
deploy_beta() {
    print_step "TestFlightにデプロイします..."
    
    # ビルドファイルの確認
    if [ ! -f "build/ipa/"*.ipa ]; then
        print_error "IPAファイルが見つかりません。"
        echo "先に './build_enhanced.sh' を実行してください。"
        exit 1
    fi
    
    bundle exec fastlane beta
    print_success "TestFlightへのデプロイ完了！"
}

# --- App Storeリリース ---
deploy_release() {
    print_step "App Storeにリリースします..."
    
    # メタデータの確認
    if [ ! -d "fastlane/metadata" ]; then
        print_error "メタデータが見つかりません。"
        echo "./setup_metadata.sh を実行してメタデータを準備してください。"
        exit 1
    fi
    
    # 確認プロンプト
    echo -e "${YELLOW}⚠️  App Storeへのリリースを実行します。${NC}"
    read -p "続行しますか？ (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "キャンセルしました。"
        exit 0
    fi
    
    bundle exec fastlane release
    print_success "App Storeへのリリース申請完了！"
}

# --- メタデータ更新 ---
update_metadata() {
    print_step "メタデータを更新します..."
    
    bundle exec fastlane update_metadata
    print_success "メタデータ更新完了！"
}

# --- ヘルプ表示 ---
show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  test          テストを実行"
    echo "  screenshots   スクリーンショットを生成"
    echo "  beta          TestFlightにデプロイ"
    echo "  release       App Storeにリリース"
    echo "  metadata      メタデータのみ更新"
    echo "  help          このヘルプを表示"
    echo ""
    echo "Examples:"
    echo "  $0 beta       # TestFlightにデプロイ"
    echo "  $0 release    # App Storeにリリース"
}

# --- メイン処理 ---
main() {
    print_header
    
    if [ $# -eq 0 ]; then
        show_help
        exit 1
    fi
    
    local command=$1
    
    case $command in
        "help"|"-h"|"--help")
            show_help
            exit 0
            ;;
        "test")
            check_config
            check_fastfile
            bundle exec fastlane test
            ;;
        "screenshots")
            check_config
            check_fastfile
            generate_screenshots
            ;;
        "beta")
            check_config
            check_fastfile
            deploy_beta
            ;;
        "release")
            check_config
            check_fastfile
            deploy_release
            ;;
        "metadata")
            check_config
            check_fastfile
            update_metadata
            ;;
        *)
            print_error "不明なコマンド: $command"
            show_help
            exit 1
            ;;
    esac
}

# 実行
main "$@"