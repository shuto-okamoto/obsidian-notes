#!/usr/bin/env ruby

# Apple ID認証情報検証スクリプト
# Fastlane不要でApple ID形式をチェック

require 'net/http'
require 'uri'

def load_env_file
  env_vars = {}
  File.readlines('.env').each do |line|
    line = line.strip
    next if line.empty? || line.start_with?('#')
    
    key, value = line.split('=', 2)
    env_vars[key] = value if key && value
  end
  env_vars
end

def validate_apple_id(apple_id)
  puts "🔍 Apple ID検証: #{apple_id}"
  
  # 基本的なメール形式チェック
  if apple_id =~ /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    puts "✅ Apple ID形式: 正常"
    return true
  else
    puts "❌ Apple ID形式: 不正"
    return false
  end
end

def validate_app_specific_password(password)
  puts "🔍 App-Specific Password検証: #{password[0..3]}****"
  
  # App-Specific Passwordの形式チェック
  # 通常16文字（4-4-4-4形式）または単一文字列
  if password.length >= 8 && password.length <= 20
    puts "✅ Password長さ: 正常 (#{password.length}文字)"
    return true
  else
    puts "❌ Password長さ: 異常 (#{password.length}文字)"
    puts "   App-Specific Passwordは通常8-20文字です"
    return false
  end
end

def test_apple_developer_connection(apple_id, password)
  puts "🔍 Apple Developer接続テスト..."
  
  begin
    # Apple IDの基本的な接続テスト（HTTPSチェック）
    uri = URI('https://idmsa.apple.com/appleauth/auth/signin')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 10
    
    response = http.head(uri.path)
    
    if response.code.to_i < 400
      puts "✅ Apple認証サーバー接続: 正常"
      return true
    else
      puts "⚠️  Apple認証サーバー接続: レスポンス #{response.code}"
      return false
    end
  rescue => e
    puts "❌ Apple認証サーバー接続エラー: #{e.message}"
    return false
  end
end

def main
  puts "🚀 Apple ID認証情報検証開始"
  puts "=" * 50
  
  # .envファイル読み込み
  begin
    env_vars = load_env_file
    puts "✅ .envファイル読み込み完了"
  rescue => e
    puts "❌ .envファイル読み込みエラー: #{e.message}"
    exit 1
  end
  
  apple_id = env_vars['FASTLANE_APPLE_ID']
  password = env_vars['FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD']
  
  if !apple_id || !password
    puts "❌ 必要な環境変数が見つかりません"
    puts "   FASTLANE_APPLE_ID: #{apple_id ? '設定済み' : '未設定'}"
    puts "   FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD: #{password ? '設定済み' : '未設定'}"
    exit 1
  end
  
  puts ""
  
  # 検証実行
  apple_id_valid = validate_apple_id(apple_id)
  password_valid = validate_app_specific_password(password)
  connection_ok = test_apple_developer_connection(apple_id, password)
  
  puts ""
  puts "=" * 50
  puts "🎯 検証結果"
  puts "Apple ID形式: #{apple_id_valid ? '✅ 正常' : '❌ 異常'}"
  puts "Password形式: #{password_valid ? '✅ 正常' : '❌ 異常'}"
  puts "接続テスト: #{connection_ok ? '✅ 正常' : '⚠️  要確認'}"
  
  if apple_id_valid && password_valid
    puts ""
    puts "🎉 認証情報形式確認完了！"
    puts "🚀 Fastlane実行準備OK"
  else
    puts ""
    puts "⚠️  認証情報の修正が必要です"
    puts "Apple ID: https://appleid.apple.com でApp-Specific Password再生成を推奨"
  end
end

main