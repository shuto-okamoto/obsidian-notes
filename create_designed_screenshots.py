#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Obsidian Notes - App Store Connect用デザインスクリーンショット作成
カレンダーアプリのスクリーンショットを参考に、Obsidian Notesアプリのスクリーンショットを作成
"""

import os
from PIL import Image, ImageDraw, ImageFont
import sys

def create_screenshot_template(width=1290, height=2796):
    """iPhone 15 Pro Max サイズのスクリーンショットテンプレート作成"""
    # 背景色 (Obsidianのダークテーマ)
    bg_color = (23, 23, 32)  # #171720
    
    # 新しい画像を作成
    img = Image.new('RGB', (width, height), bg_color)
    draw = ImageDraw.Draw(img)
    
    return img, draw

def add_status_bar(draw, width):
    """ステータスバー追加"""
    # 時刻 (左上)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 34)
    except:
        font = ImageFont.load_default()
    
    draw.text((54, 59), "9:41", fill=(255, 255, 255), font=font)
    
    # バッテリーとWiFiアイコン (右上) - 簡単な矩形で代用
    draw.rectangle([width-150, 55, width-100, 75], fill=(255, 255, 255))
    draw.rectangle([width-90, 55, width-40, 75], fill=(255, 255, 255))

def add_navigation_bar(draw, width, y_pos=120):
    """ナビゲーションバー追加"""
    try:
        title_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 38)
    except:
        title_font = ImageFont.load_default()
    
    # タイトル
    title = "Obsidian Notes"
    bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = bbox[2] - bbox[0]
    x = (width - title_width) // 2
    draw.text((x, y_pos), title, fill=(255, 255, 255), font=title_font)

def add_memo_list(draw, width, height):
    """メモリスト追加"""
    try:
        memo_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 32)
        date_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 24)
    except:
        memo_font = ImageFont.load_default()
        date_font = ImageFont.load_default()
    
    # メモアイテムのデータ
    memos = [
        {"title": "今日の振り返り", "date": "2025年7月30日", "preview": "今日は新しいアプリの開発について学んだ..."},
        {"title": "プロジェクトのアイデア", "date": "2025年7月29日", "preview": "Obsidianのようなメモアプリを作る計画..."},
        {"title": "学習メモ", "date": "2025年7月28日", "preview": "SwiftUIの基本的な使い方について..."},
        {"title": "会議の記録", "date": "2025年7月27日", "preview": "チームミーティングでの重要な決定事項..."},
    ]
    
    start_y = 220
    item_height = 120
    
    for i, memo in enumerate(memos):
        y = start_y + (i * item_height)
        
        # メモアイテムの背景 (少し明るい色)
        draw.rectangle([40, y, width-40, y+100], fill=(40, 40, 50), outline=(80, 80, 90))
        
        # タイトル
        draw.text((60, y+15), memo["title"], fill=(255, 255, 255), font=memo_font)
        
        # 日付
        draw.text((60, y+50), memo["date"], fill=(150, 150, 150), font=date_font)
        
        # プレビューテキスト
        draw.text((60, y+75), memo["preview"][:30] + "...", fill=(200, 200, 200), font=date_font)

def add_floating_action_button(draw, width, height):
    """フローティングアクションボタン (+ ボタン)"""
    # ボタンの位置とサイズ
    button_size = 120
    button_x = width - button_size - 60
    button_y = height - button_size - 200
    
    # 円形ボタン
    draw.ellipse([button_x, button_y, button_x + button_size, button_y + button_size], 
                fill=(138, 43, 226), outline=(160, 70, 240))  # パープル
    
    # + アイコン
    center_x = button_x + button_size // 2
    center_y = button_y + button_size // 2
    
    # 水平線
    draw.rectangle([center_x - 25, center_y - 4, center_x + 25, center_y + 4], fill=(255, 255, 255))
    # 垂直線
    draw.rectangle([center_x - 4, center_y - 25, center_x + 4, center_y + 25], fill=(255, 255, 255))

def add_japanese_text_overlay(draw, width, height):
    """日本語テキストオーバーレイ追加 (App Store用)"""
    try:
        overlay_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 72)
        subtitle_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 48)
    except:
        overlay_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    # 半透明の背景
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    
    # メインキャッチコピー
    main_text = "1日間分の"
    sub_text = "時給で"
    
    # テキストの位置計算
    bbox1 = overlay_draw.textbbox((0, 0), main_text, font=overlay_font)
    bbox2 = overlay_draw.textbbox((0, 0), sub_text, font=overlay_font)
    
    text1_width = bbox1[2] - bbox1[0]
    text2_width = bbox2[2] - bbox2[0]
    
    # 中央配置
    x1 = (width - text1_width) // 2
    x2 = (width - text2_width) // 2
    
    y1 = height // 2 - 150
    y2 = height // 2 - 50
    
    # テキストシャドウ (黒)
    shadow_offset = 3
    overlay_draw.text((x1 + shadow_offset, y1 + shadow_offset), main_text, fill=(0, 0, 0, 180), font=overlay_font)
    overlay_draw.text((x2 + shadow_offset, y2 + shadow_offset), sub_text, fill=(0, 0, 0, 180), font=overlay_font)
    
    # メインテキスト (白)
    overlay_draw.text((x1, y1), main_text, fill=(255, 255, 255, 255), font=overlay_font)
    overlay_draw.text((x2, y2), sub_text, fill=(255, 255, 255, 255), font=overlay_font)
    
    return overlay

def create_screenshot_1():
    """[Image #1] メイン画面のスクリーンショット"""
    img, draw = create_screenshot_template()
    width, height = img.size
    
    # UI要素を追加
    add_status_bar(draw, width)
    add_navigation_bar(draw, width)
    add_memo_list(draw, width, height)
    add_floating_action_button(draw, width, height)
    
    # テキストオーバーレイ
    overlay = add_japanese_text_overlay(draw, width, height)
    img = Image.alpha_composite(img.convert('RGBA'), overlay).convert('RGB')
    
    return img

def create_screenshot_2():
    """[Image #2] AIシフト作成画面のスクリーンショット"""
    img, draw = create_screenshot_template()
    width, height = img.size
    
    # UI要素を追加
    add_status_bar(draw, width)
    add_navigation_bar(draw, width)
    
    # メモ作成画面
    try:
        input_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 36)
    except:
        input_font = ImageFont.load_default()
    
    # 入力エリア
    draw.rectangle([40, 200, width-40, height-300], fill=(40, 40, 50), outline=(80, 80, 90))
    
    # 入力テキスト
    sample_text = [
        "# 今日の学び",
        "",
        "## プログラミング",
        "- SwiftUIの基本構文を学習",
        "- AppFlowMVPフレームワーク活用",
        "- App Store Connect自動化",
        "",
        "## 気づき",
        "自動化により効率が大幅に向上した。",
        "特にスクリーンショット生成の部分で...",
    ]
    
    y_pos = 220
    for line in sample_text:
        draw.text((60, y_pos), line, fill=(255, 255, 255), font=input_font)
        y_pos += 45
    
    # AIシフト作成のオーバーレイテキスト
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    overlay_draw = ImageDraw.Draw(overlay)
    
    try:
        overlay_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 72)
    except:
        overlay_font = ImageFont.load_default()
    
    main_text = "AIがシフト"
    sub_text = "作成"
    
    bbox1 = overlay_draw.textbbox((0, 0), main_text, font=overlay_font)
    bbox2 = overlay_draw.textbbox((0, 0), sub_text, font=overlay_font)
    
    text1_width = bbox1[2] - bbox1[0]
    text2_width = bbox2[2] - bbox2[0]
    
    x1 = (width - text1_width) // 2
    x2 = (width - text2_width) // 2
    
    y1 = height // 2 + 200
    y2 = height // 2 + 300
    
    overlay_draw.text((x1 + 3, y1 + 3), main_text, fill=(0, 0, 0, 180), font=overlay_font)
    overlay_draw.text((x2 + 3, y2 + 3), sub_text, fill=(0, 0, 0, 180), font=overlay_font)
    
    overlay_draw.text((x1, y1), main_text, fill=(255, 255, 255, 255), font=overlay_font)
    overlay_draw.text((x2, y2), sub_text, fill=(255, 255, 255, 255), font=overlay_font)
    
    img = Image.alpha_composite(img.convert('RGBA'), overlay).convert('RGB')
    
    return img

def main():
    """メイン処理"""
    # 出力ディレクトリ作成
    os.makedirs("fastlane/screenshots/ja", exist_ok=True)
    
    print("🎨 App Store Connect用スクリーンショットを作成しています...")
    
    # [Image #1] メイン画面
    screenshot1 = create_screenshot_1()
    screenshot1.save("fastlane/screenshots/ja/01_MainScreen_Designed.png", "PNG", quality=95)
    print("✅ [Image #1] メイン画面スクリーンショット作成完了")
    
    # [Image #2] AI機能画面
    screenshot2 = create_screenshot_2()
    screenshot2.save("fastlane/screenshots/ja/02_AIFeature_Designed.png", "PNG", quality=95)
    print("✅ [Image #2] AI機能スクリーンショット作成完了")
    
    print("\n🎉 App Store Connect用スクリーンショット作成完了！")
    print("📁 ファイル場所: fastlane/screenshots/ja/")
    print("")
    print("次のステップ:")
    print("1. スクリーンショットを確認")
    print("2. ./deploy.sh beta でTestFlightにアップロード")
    print("3. App Store Connectで最終確認")

if __name__ == "__main__":
    main()