#!/bin/bash

# AppFlowMVP - Metadata Setup Script
# App Store Connect用のメタデータを対話的に設定

# --- 色付け用 ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# --- ヘッダー ---
print_header() {
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE} 📝 App Store Metadata Setup${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
}

# --- 言語選択 ---
select_languages() {
    echo -e "${BLUE}対応言語を選択してください (複数選択可):${NC}"
    echo ""
    echo "1) 日本語 (ja-JP)"
    echo "2) 英語 (en-US)"
    echo "3) 中国語簡体字 (zh-Hans)"
    echo "4) 中国語繁体字 (zh-Hant)"
    echo "5) 韓国語 (ko)"
    echo "6) スペイン語 (es-ES)"
    echo "7) フランス語 (fr-FR)"
    echo "8) ドイツ語 (de-DE)"
    echo "9) イタリア語 (it)"
    echo "10) ポルトガル語 (pt-BR)"
    echo ""
    echo "例: 1,2,5 (カンマ区切りで入力)"
    read -p "選択: " language_selection
    
    # デフォルトは日本語のみ
    if [ -z "$language_selection" ]; then
        language_selection="1"
    fi
    
    # 選択された言語を配列に格納
    IFS=',' read -ra SELECTED_LANGS <<< "$language_selection"
    LANGUAGES=()
    
    for i in "${SELECTED_LANGS[@]}"; do
        case $i in
            1) LANGUAGES+=("ja-JP");;
            2) LANGUAGES+=("en-US");;
            3) LANGUAGES+=("zh-Hans");;
            4) LANGUAGES+=("zh-Hant");;
            5) LANGUAGES+=("ko");;
            6) LANGUAGES+=("es-ES");;
            7) LANGUAGES+=("fr-FR");;
            8) LANGUAGES+=("de-DE");;
            9) LANGUAGES+=("it");;
            10) LANGUAGES+=("pt-BR");;
        esac
    done
}

# --- メタデータ入力 ---
input_metadata() {
    local lang=$1
    local lang_name=$2
    
    echo ""
    echo -e "${YELLOW}=== $lang_name ($lang) のメタデータ ===${NC}"
    echo ""
    
    local metadata_dir="fastlane/metadata/$lang"
    mkdir -p "$metadata_dir"
    
    # アプリ名
    echo -e "${BLUE}アプリ名 (30文字以内):${NC}"
    read -p "> " app_name
    echo "$app_name" > "$metadata_dir/name.txt"
    
    # サブタイトル
    echo -e "${BLUE}サブタイトル (30文字以内) [オプション]:${NC}"
    read -p "> " subtitle
    if [ ! -z "$subtitle" ]; then
        echo "$subtitle" > "$metadata_dir/subtitle.txt"
    fi
    
    # プロモーションテキスト
    echo -e "${BLUE}プロモーションテキスト (170文字以内):${NC}"
    echo "例: 期間限定セール中！今なら全機能が50%オフ"
    read -p "> " promotional_text
    echo "$promotional_text" > "$metadata_dir/promotional_text.txt"
    
    # キーワード
    echo -e "${BLUE}キーワード (カンマ区切り、100文字以内):${NC}"
    echo "例: 写真,編集,フィルター,カメラ,SNS"
    read -p "> " keywords
    echo "$keywords" > "$metadata_dir/keywords.txt"
    
    # 説明文
    echo -e "${BLUE}アプリの説明 (4000文字以内):${NC}"
    echo "複数行入力可能です。入力を終了するには空行でEnterを2回押してください。"
    echo ""
    
    description=""
    while IFS= read -r line; do
        [ -z "$line" ] && break
        description="${description}${line}\n"
    done
    
    echo -e "$description" > "$metadata_dir/description.txt"
    
    # 新機能
    echo -e "${BLUE}新機能の説明 (4000文字以内) [オプション]:${NC}"
    echo "アップデート時の「このバージョンの新機能」に表示されます。"
    echo "空行でEnterを2回押して終了。スキップする場合は最初にEnterを押してください。"
    echo ""
    
    release_notes=""
    while IFS= read -r line; do
        [ -z "$line" ] && break
        release_notes="${release_notes}${line}\n"
    done
    
    if [ ! -z "$release_notes" ]; then
        echo -e "$release_notes" > "$metadata_dir/release_notes.txt"
    fi
    
    # URL（最初の言語でのみ入力）
    if [ "$lang" == "${LANGUAGES[0]}" ]; then
        # config/app_config.ymlから読み込み
        if [ -f "config/app_config.yml" ]; then
            marketing_url=$(yq eval '.urls.website' config/app_config.yml)
            privacy_url=$(yq eval '.urls.privacy_policy' config/app_config.yml)
            support_url=$(yq eval '.urls.support' config/app_config.yml)
        fi
        
        echo "$marketing_url" > "$metadata_dir/marketing_url.txt"
        echo "$privacy_url" > "$metadata_dir/privacy_url.txt"
        echo "$support_url" > "$metadata_dir/support_url.txt"
    else
        # 他の言語では最初の言語からコピー
        cp "fastlane/metadata/${LANGUAGES[0]}/marketing_url.txt" "$metadata_dir/" 2>/dev/null || true
        cp "fastlane/metadata/${LANGUAGES[0]}/privacy_url.txt" "$metadata_dir/" 2>/dev/null || true
        cp "fastlane/metadata/${LANGUAGES[0]}/support_url.txt" "$metadata_dir/" 2>/dev/null || true
    fi
}

# --- AI翻訳用プロンプト生成 ---
generate_translation_prompt() {
    echo -e "${BLUE}AI翻訳用のプロンプトを生成しています...${NC}"
    
    local base_lang="${LANGUAGES[0]}"
    local prompt_file="prompts/translate_metadata.txt"
    mkdir -p prompts
    
    cat > "$prompt_file" << 'EOF'
以下のApp Storeメタデータを他の言語に翻訳してください。
アプリストアに最適化された、自然で魅力的な翻訳を心がけてください。

【翻訳元データ】
EOF
    
    # 基準言語のメタデータを追加
    echo "" >> "$prompt_file"
    echo "アプリ名: $(cat fastlane/metadata/$base_lang/name.txt)" >> "$prompt_file"
    
    if [ -f "fastlane/metadata/$base_lang/subtitle.txt" ]; then
        echo "サブタイトル: $(cat fastlane/metadata/$base_lang/subtitle.txt)" >> "$prompt_file"
    fi
    
    echo "プロモーションテキスト: $(cat fastlane/metadata/$base_lang/promotional_text.txt)" >> "$prompt_file"
    echo "キーワード: $(cat fastlane/metadata/$base_lang/keywords.txt)" >> "$prompt_file"
    echo "" >> "$prompt_file"
    echo "説明文:" >> "$prompt_file"
    cat "fastlane/metadata/$base_lang/description.txt" >> "$prompt_file"
    
    echo "" >> "$prompt_file"
    echo "【翻訳先言語】" >> "$prompt_file"
    for lang in "${LANGUAGES[@]:1}"; do
        case $lang in
            "en-US") echo "- 英語 (en-US)" >> "$prompt_file";;
            "zh-Hans") echo "- 中国語簡体字 (zh-Hans)" >> "$prompt_file";;
            "zh-Hant") echo "- 中国語繁体字 (zh-Hant)" >> "$prompt_file";;
            "ko") echo "- 韓国語 (ko)" >> "$prompt_file";;
            "es-ES") echo "- スペイン語 (es-ES)" >> "$prompt_file";;
            "fr-FR") echo "- フランス語 (fr-FR)" >> "$prompt_file";;
            "de-DE") echo "- ドイツ語 (de-DE)" >> "$prompt_file";;
            "it") echo "- イタリア語 (it)" >> "$prompt_file";;
            "pt-BR") echo "- ポルトガル語 (pt-BR)" >> "$prompt_file";;
        esac
    done
    
    cat >> "$prompt_file" << 'EOF'

【翻訳時の注意事項】
1. 各言語の文字数制限を守ってください
   - アプリ名: 30文字
   - サブタイトル: 30文字
   - プロモーションテキスト: 170文字
   - キーワード: 100文字（カンマ区切り）
   
2. 各言語の文化や慣習に配慮した表現を使用してください

3. キーワードは、その言語圏でよく検索される単語を選んでください

4. 以下の形式で出力してください：

=== 言語コード ===
アプリ名: [翻訳]
サブタイトル: [翻訳]
プロモーションテキスト: [翻訳]
キーワード: [翻訳]
説明文:
[翻訳]
===
EOF
    
    echo ""
    echo -e "${GREEN}翻訳プロンプトを生成しました: $prompt_file${NC}"
    echo "このファイルの内容をChatGPTやClaudeに渡して翻訳を依頼してください。"
}

# --- スクリーンショット用テキスト ---
create_screenshot_texts() {
    echo -e "${BLUE}スクリーンショット用のテキストを設定しています...${NC}"
    
    for lang in "${LANGUAGES[@]}"; do
        local screenshot_dir="fastlane/screenshots/$lang"
        mkdir -p "$screenshot_dir"
        
        # スクリーンショット用のテキストファイル作成
        cat > "$screenshot_dir/screenshot_texts.json" << EOF
{
  "screenshots": [
    {
      "filename": "1_main_screen",
      "title": "シンプルで使いやすい",
      "subtitle": "直感的な操作性"
    },
    {
      "filename": "2_feature_1",
      "title": "パワフルな機能",
      "subtitle": "あなたの作業を効率化"
    },
    {
      "filename": "3_feature_2", 
      "title": "安全・安心",
      "subtitle": "プライバシーを保護"
    },
    {
      "filename": "4_feature_3",
      "title": "いつでもどこでも",
      "subtitle": "オフラインでも使える"
    },
    {
      "filename": "5_feature_4",
      "title": "今すぐ始めよう",
      "subtitle": "無料でダウンロード"
    }
  ]
}
EOF
    done
}

# --- レビュー情報設定 ---
setup_review_info() {
    echo ""
    echo -e "${BLUE}App Store審査用の情報を設定します:${NC}"
    echo ""
    
    local review_info_file="fastlane/metadata/review_information"
    mkdir -p "$(dirname "$review_info_file")"
    
    # 連絡先情報
    read -p "審査連絡用の名前 (First name): " first_name
    read -p "審査連絡用の名前 (Last name): " last_name
    read -p "審査連絡用の電話番号: " phone_number
    read -p "審査連絡用のメールアドレス: " email_address
    
    # デモアカウント（必要な場合）
    echo ""
    echo -e "${YELLOW}アプリにログイン機能がある場合、デモアカウントを設定してください。${NC}"
    echo "ない場合は空欄でEnterを押してください。"
    read -p "デモユーザー名: " demo_user
    read -p "デモパスワード: " demo_password
    
    # 審査メモ
    echo ""
    echo -e "${BLUE}審査担当者への追加情報 (オプション):${NC}"
    echo "特別な操作方法や注意事項があれば記入してください。"
    echo "複数行入力可能。終了するには空行でEnterを2回押してください。"
    
    notes=""
    while IFS= read -r line; do
        [ -z "$line" ] && break
        notes="${notes}${line}\n"
    done
    
    # レビュー情報を保存
    cat > "$review_info_file" << EOF
first_name: $first_name
last_name: $last_name
phone_number: $phone_number
email_address: $email_address
demo_user: $demo_user
demo_password: $demo_password
notes: |
$(echo -e "$notes" | sed 's/^/  /')
EOF
    
    echo -e "${GREEN}審査情報を保存しました。${NC}"
}

# --- メイン処理 ---
main() {
    print_header
    
    # 設定ファイル確認
    if [ ! -f "config/app_config.yml" ]; then
        echo -e "${RED}エラー: 設定ファイルが見つかりません。${NC}"
        echo "先に './initialize_app.sh' を実行してください。"
        exit 1
    fi
    
    # 言語選択
    select_languages
    
    echo ""
    echo -e "${GREEN}選択された言語: ${LANGUAGES[@]}${NC}"
    echo ""
    
    # 各言語のメタデータ入力
    for i in "${!LANGUAGES[@]}"; do
        lang="${LANGUAGES[$i]}"
        case $lang in
            "ja-JP") lang_name="日本語";;
            "en-US") lang_name="英語";;
            "zh-Hans") lang_name="中国語簡体字";;
            "zh-Hant") lang_name="中国語繁体字";;
            "ko") lang_name="韓国語";;
            "es-ES") lang_name="スペイン語";;
            "fr-FR") lang_name="フランス語";;
            "de-DE") lang_name="ドイツ語";;
            "it") lang_name="イタリア語";;
            "pt-BR") lang_name="ポルトガル語";;
        esac
        
        input_metadata "$lang" "$lang_name"
    done
    
    # 複数言語の場合、翻訳プロンプトを生成
    if [ ${#LANGUAGES[@]} -gt 1 ]; then
        echo ""
        read -p "AI翻訳用のプロンプトを生成しますか？ (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            generate_translation_prompt
        fi
    fi
    
    # スクリーンショット用テキスト作成
    create_screenshot_texts
    
    # レビュー情報設定
    setup_review_info
    
    # 完了メッセージ
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN} ✅ メタデータの設定が完了しました！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}次のステップ:${NC}"
    echo "1. fastlane/metadata/ 内のファイルを確認・編集"
    echo "2. ./deploy.sh screenshots でスクリーンショット生成"
    echo "3. ./deploy.sh metadata でメタデータのみ更新"
    echo "4. ./deploy.sh release でApp Storeに申請"
    echo ""
    
    if [ -f "prompts/translate_metadata.txt" ]; then
        echo -e "${YELLOW}ヒント:${NC}"
        echo "翻訳が必要な場合は prompts/translate_metadata.txt を"
        echo "ChatGPTやClaudeに渡してください。"
    fi
}

# 実行
main