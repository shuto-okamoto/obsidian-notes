#!/bin/bash

# Obsidian Notes - URL更新スクリプト
# 実用的なサポート/プライバシーURLに更新

# 色付け用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_header() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE} 🔧 Obsidian Notes URL Update${NC}"
    echo -e "${PURPLE}    実用的なサポートURL設定${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
}

print_step() {
    echo -e "${YELLOW}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# GitHubリポジトリURL（作成推奨）
GITHUB_REPO_URL="https://github.com/okamotohideto/obsidian-notes"
# サポートメール
SUPPORT_EMAIL="clows.zero@icloud.com"

# URL更新
update_urls() {
    print_step "実用的なURLに更新しています..."
    
    # サポートURL（GitHubのIssuesページまたはメール）
    echo "mailto:${SUPPORT_EMAIL}?subject=Obsidian%20Notes%20Support" > fastlane/metadata/en-US/support_url.txt
    echo "mailto:${SUPPORT_EMAIL}?subject=Obsidian%20Notes%20サポート" > fastlane/metadata/ja-JP/support_url.txt
    
    # プライバシーポリシーURL（GitHubのWikiまたはREADME）
    echo "${GITHUB_REPO_URL}#privacy-policy" > fastlane/metadata/en-US/privacy_url.txt
    echo "${GITHUB_REPO_URL}#privacy-policy" > fastlane/metadata/ja-JP/privacy_url.txt
    
    # マーケティングURL（GitHubリポジトリ）
    echo "${GITHUB_REPO_URL}" > fastlane/metadata/en-US/marketing_url.txt
    echo "${GITHUB_REPO_URL}" > fastlane/metadata/ja-JP/marketing_url.txt
    
    print_success "URL更新完了"
}

# プライバシーポリシーのサンプル作成
create_privacy_policy() {
    print_step "プライバシーポリシーサンプルを作成しています..."
    
    cat > PRIVACY_POLICY.md << 'EOF'
# Privacy Policy for Obsidian Notes

## Data Collection
Obsidian Notes does not collect any personal data. All notes are stored locally on your device.

## Data Storage
- All data is stored locally on your device
- No data is transmitted to external servers
- No analytics or tracking is performed

## Contact
For questions about this privacy policy, contact: clows.zero@icloud.com

---

# プライバシーポリシー - Obsidian Notes

## データ収集
Obsidian Notesは個人データを収集しません。すべてのメモはデバイスにローカル保存されます。

## データ保存
- すべてのデータはデバイスにローカル保存
- 外部サーバーへのデータ送信なし
- 分析やトラッキングなし

## お問い合わせ
プライバシーポリシーに関するお問い合わせ: clows.zero@icloud.com
EOF
    
    print_success "プライバシーポリシー作成完了"
}

# config更新
update_config() {
    print_step "config/app_config.ymlを更新しています..."
    
    # URLセクションを更新
    sed -i '' "s|website: .*|website: \"${GITHUB_REPO_URL}\"|" config/app_config.yml
    sed -i '' "s|privacy_policy: .*|privacy_policy: \"${GITHUB_REPO_URL}#privacy-policy\"|" config/app_config.yml
    sed -i '' "s|support: .*|support: \"mailto:${SUPPORT_EMAIL}\"|" config/app_config.yml
    
    print_success "設定ファイル更新完了"
}

# 確認表示
show_urls() {
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN} 🎉 URL設定更新完了！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}設定されたURL:${NC}"
    echo ""
    echo "📧 サポートURL: mailto:${SUPPORT_EMAIL}"
    echo "🔒 プライバシーポリシー: ${GITHUB_REPO_URL}#privacy-policy"
    echo "🌐 マーケティング: ${GITHUB_REPO_URL}"
    echo ""
    echo -e "${YELLOW}推奨アクション:${NC}"
    echo "1. GitHubで ${GITHUB_REPO_URL} リポジトリを作成"
    echo "2. PRIVACY_POLICY.mdをREADMEに追加"
    echo "3. App Store Connectで確認"
    echo ""
    echo -e "${PURPLE}🚀 App Store Connect対応URL準備完了！${NC}"
}

# メイン処理
main() {
    print_header
    update_urls
    create_privacy_policy
    update_config
    show_urls
}

# 実行
main