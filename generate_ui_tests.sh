#!/bin/bash

# AppFlowMVP - UI Test Generator
# スクリーンショット用のUIテストを自動生成

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
    echo -e "${PURPLE} 🧪 UI Test Generator${NC}"
    echo -e "${PURPLE}    スクリーンショット用テスト自動生成${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
}

# --- プロジェクト検出 ---
find_test_target() {
    # UITestsターゲットを探す
    local test_target=$(find . -name "*UITests" -type d | grep -v "DerivedData" | head -1)
    
    if [ -z "$test_target" ]; then
        echo -e "${YELLOW}UITestsターゲットが見つかりません。作成しますか？${NC}"
        read -p "(y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_uitest_target
        else
            exit 1
        fi
    else
        echo -e "${GREEN}UITestsターゲットを発見: $test_target${NC}"
        UI_TEST_DIR="$test_target"
    fi
}

# --- UITestターゲット作成 ---
create_uitest_target() {
    # プロジェクト名を取得
    local project_name=$(find . -name "*.xcodeproj" | head -1 | xargs basename | sed 's/.xcodeproj//')
    
    if [ -z "$project_name" ]; then
        echo -e "${RED}Xcodeプロジェクトが見つかりません。${NC}"
        exit 1
    fi
    
    UI_TEST_DIR="${project_name}UITests"
    mkdir -p "$UI_TEST_DIR"
    
    echo -e "${GREEN}UITestsディレクトリを作成しました: $UI_TEST_DIR${NC}"
}

# --- SwiftUIテスト生成 ---
generate_swiftui_tests() {
    cat > "$UI_TEST_DIR/ScreenshotUITests.swift" << 'EOF'
import XCTest

class ScreenshotUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testTakeScreenshots() throws {
        let app = XCUIApplication()
        
        // スクリーンショット1: メイン画面
        sleep(2) // 画面が完全に読み込まれるまで待機
        snapshot("01_MainScreen")
        
        // タブがある場合の例
        if app.tabBars.firstMatch.exists {
            // 各タブのスクリーンショット
            let tabBar = app.tabBars.firstMatch
            let tabButtons = tabBar.buttons
            
            for i in 0..<min(tabButtons.count, 4) {
                tabButtons.element(boundBy: i).tap()
                sleep(1)
                snapshot("0\(i+2)_Tab\(i+1)")
            }
        }
        
        // ナビゲーションがある場合の例
        if app.navigationBars.firstMatch.exists {
            // 設定画面などを探す
            let settingsButton = app.navigationBars.buttons["Settings"]
            if settingsButton.exists {
                settingsButton.tap()
                sleep(1)
                snapshot("05_Settings")
            }
        }
        
        // ボタンをタップする例
        let primaryButtons = app.buttons.matching(identifier: "PrimaryButton")
        if primaryButtons.count > 0 {
            primaryButtons.firstMatch.tap()
            sleep(1)
            snapshot("06_Feature")
        }
        
        // モーダル表示の例
        let addButton = app.buttons["Add"]
        if addButton.exists {
            addButton.tap()
            sleep(1)
            snapshot("07_AddModal")
            
            // モーダルを閉じる
            let cancelButton = app.buttons["Cancel"]
            if cancelButton.exists {
                cancelButton.tap()
            }
        }
    }
    
    func testLocalizedScreenshots() throws {
        // 言語別のスクリーンショット
        let app = XCUIApplication()
        
        // 日本語
        app.launchArguments = ["-AppleLanguages", "(ja)"]
        app.launch()
        snapshot("01_MainScreen_ja")
        
        // 英語
        app.terminate()
        app.launchArguments = ["-AppleLanguages", "(en)"]
        app.launch()
        snapshot("01_MainScreen_en")
    }
}

// MARK: - Helper Extensions

extension XCUIElement {
    func waitForExistence(timeout: TimeInterval = 5) -> Bool {
        return self.waitForExistence(timeout: timeout)
    }
    
    func tapIfExists() {
        if self.exists {
            self.tap()
        }
    }
}
EOF
    
    echo -e "${GREEN}SwiftUI用のUIテストを生成しました${NC}"
}

# --- UIKitテスト生成 ---
generate_uikit_tests() {
    cat > "$UI_TEST_DIR/ScreenshotUITests.swift" << 'EOF'
import XCTest

class ScreenshotUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testTakeScreenshots() throws {
        let app = XCUIApplication()
        
        // スクリーンショット1: 起動画面
        sleep(2)
        snapshot("01_LaunchScreen")
        
        // ログイン画面がある場合
        let loginButton = app.buttons["Login"]
        if loginButton.exists {
            // デモアカウントでログイン
            let usernameField = app.textFields["Username"]
            let passwordField = app.secureTextFields["Password"]
            
            if usernameField.exists && passwordField.exists {
                usernameField.tap()
                usernameField.typeText("demo@example.com")
                
                passwordField.tap()
                passwordField.typeText("demo123")
                
                loginButton.tap()
                sleep(2)
            }
        }
        
        // メイン画面
        snapshot("02_MainScreen")
        
        // TableViewがある場合
        let tableViews = app.tables
        if tableViews.count > 0 {
            let table = tableViews.firstMatch
            
            // 最初のセルをタップ
            if table.cells.count > 0 {
                table.cells.element(boundBy: 0).tap()
                sleep(1)
                snapshot("03_DetailView")
                
                // 戻る
                app.navigationBars.buttons.firstMatch.tap()
            }
        }
        
        // CollectionViewがある場合
        let collectionViews = app.collectionViews
        if collectionViews.count > 0 {
            let collection = collectionViews.firstMatch
            
            if collection.cells.count > 0 {
                collection.cells.element(boundBy: 0).tap()
                sleep(1)
                snapshot("04_ItemDetail")
            }
        }
        
        // アクションシートの例
        let moreButton = app.buttons["More"]
        if moreButton.exists {
            moreButton.tap()
            sleep(1)
            snapshot("05_ActionSheet")
            
            // キャンセル
            app.buttons["Cancel"].tapIfExists()
        }
    }
    
    func testScrollableContent() throws {
        let app = XCUIApplication()
        
        // スクロール可能なコンテンツ
        let scrollViews = app.scrollViews
        if scrollViews.count > 0 {
            let scrollView = scrollViews.firstMatch
            
            // 下にスクロール
            scrollView.swipeUp()
            sleep(1)
            snapshot("06_ScrolledContent")
        }
    }
}

extension XCUIElement {
    func tapIfExists() {
        if self.exists {
            self.tap()
        }
    }
}
EOF
    
    echo -e "${GREEN}UIKit用のUIテストを生成しました${NC}"
}

# --- Flutterテスト生成 ---
generate_flutter_tests() {
    # Flutter用のUIテストはDartで書く必要があるため、
    # 代わりにXcodeのUIテストでFlutterアプリをテストする方法を生成
    
    cat > "$UI_TEST_DIR/ScreenshotUITests.swift" << 'EOF'
import XCTest

class ScreenshotUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testFlutterAppScreenshots() throws {
        let app = XCUIApplication()
        
        // Flutterアプリは要素の特定が難しいため、
        // 座標ベースまたは待機時間でスクリーンショットを撮る
        
        // 起動画面
        sleep(3) // Flutterの初期化を待つ
        snapshot("01_MainScreen")
        
        // 画面の中央付近をタップ（ボタンがあると仮定）
        let screenCenter = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        screenCenter.tap()
        sleep(2)
        snapshot("02_SecondScreen")
        
        // 左上（戻るボタンの位置）をタップ
        let backButton = app.coordinate(withNormalizedOffset: CGVector(dx: 0.1, dy: 0.1))
        backButton.tap()
        sleep(1)
        
        // 右下（FABの位置）をタップ
        let fabButton = app.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.9))
        fabButton.tap()
        sleep(2)
        snapshot("03_ModalScreen")
        
        // スワイプ操作
        app.swipeLeft()
        sleep(1)
        snapshot("04_SwipedScreen")
        
        app.swipeRight()
        sleep(1)
        
        // 下にスクロール
        app.swipeUp()
        sleep(1)
        snapshot("05_ScrolledContent")
    }
}
EOF
    
    echo -e "${GREEN}Flutter用のUIテストを生成しました${NC}"
    echo -e "${YELLOW}注: Flutterアプリの要素特定は制限があるため、座標ベースのテストになっています${NC}"
}

# --- テストスキーム設定 ---
create_test_scheme() {
    echo -e "${BLUE}UIテスト用のスキーム設定を追加しています...${NC}"
    
    # Fastlane Snapfile 作成
    mkdir -p fastlane
    
    if [ ! -f "fastlane/Snapfile" ]; then
        cat > "fastlane/Snapfile" << 'EOF'
# Snapfile Configuration

devices([
  "iPhone 15 Pro Max",
  "iPhone 15 Pro",
  "iPhone 13",
  "iPhone SE (3rd generation)",
  "iPad Pro (12.9-inch) (6th generation)"
])

languages([
  "ja-JP",
  "en-US"
])

# UIテストのスキーム名
scheme("YourAppUITests")

clear_previous_screenshots(true)
override_status_bar(true)
localize_simulator(true)

# カスタム引数
launch_arguments([
  "-FASTLANE_SNAPSHOT 1",
  "-UITestMode 1"
])

# 出力ディレクトリ
output_directory("./fastlane/screenshots")
EOF
        
        echo -e "${YELLOW}fastlane/Snapfile を編集してスキーム名を更新してください${NC}"
    fi
}

# --- ヘルパーファイル生成 ---
create_snapshot_helper() {
    cat > "$UI_TEST_DIR/SnapshotHelper.swift" << 'EOF'
//
//  SnapshotHelper.swift
//  Generated by fastlane snapshot
//

import Foundation
import XCTest

var deviceLanguage = ""
var locale = ""

func setupSnapshot(_ app: XCUIApplication) {
    Snapshot.setupSnapshot(app)
}

func snapshot(_ name: String, timeWaitingForIdle timeout: TimeInterval = 20) {
    Snapshot.snapshot(name, timeWaitingForIdle: timeout)
}

open class Snapshot: NSObject {
    static var app: XCUIApplication!
    static var cacheDirectory: URL!
    static var screenshotsDirectory: URL!

    open class func setupSnapshot(_ app: XCUIApplication) {
        Snapshot.app = app

        do {
            let cacheDir = try pathPrefix()
            Snapshot.cacheDirectory = cacheDir
            Snapshot.screenshotsDirectory = cacheDir.appendingPathComponent("screenshots", isDirectory: true)
            
            try FileManager.default.createDirectory(at: screenshotsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Failed to create screenshots directory: \(error)")
        }
    }

    class func snapshot(_ name: String, timeWaitingForIdle timeout: TimeInterval = 20) {
        if timeout > 0 {
            waitForLoadingIndicatorToDisappear(within: timeout)
        }

        print("snapshot: \(name)")
        sleep(1)
        
        let screenshot = app.windows.firstMatch.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    
    class func waitForLoadingIndicatorToDisappear(within timeout: TimeInterval) {
        let networkLoadingIndicator = XCUIApplication().otherElements.deviceStatusBars.networkLoadingIndicators.element
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            if !networkLoadingIndicator.exists { break }
            sleep(1)
        }
    }
    
    class func pathPrefix() throws -> URL {
        let homeDir = URL(fileURLWithPath: NSHomeDirectory())
        return homeDir.appendingPathComponent("Library/Caches/tools.fastlane")
    }
}

extension XCUIElement {
    var deviceStatusBars: XCUIElementQuery {
        let containerType = XCUIElement.ElementType.init(rawValue: 46)!
        return self.descendants(matching: containerType)
    }
    
    var networkLoadingIndicators: XCUIElementQuery {
        let networkLoadingIndicatorType = XCUIElement.ElementType.init(rawValue: 58)!
        return self.descendants(matching: networkLoadingIndicatorType)
    }
}
EOF
    
    echo -e "${GREEN}SnapshotHelper.swift を生成しました${NC}"
}

# --- メイン処理 ---
main() {
    print_header
    
    # UITestターゲットを探す
    find_test_target
    
    # プロジェクトタイプを判定
    echo -e "${BLUE}プロジェクトタイプを選択してください:${NC}"
    echo "1) SwiftUI"
    echo "2) UIKit"
    echo "3) Flutter"
    echo "4) React Native"
    echo "5) その他/不明"
    read -p "選択 (1-5) [デフォルト: 1]: " project_type
    
    case $project_type in
        2) generate_uikit_tests;;
        3) generate_flutter_tests;;
        4) generate_flutter_tests;; # React NativeもFlutterと同様の方法
        5) generate_swiftui_tests;;
        *) generate_swiftui_tests;;
    esac
    
    # ヘルパーファイル生成
    create_snapshot_helper
    
    # テストスキーム設定
    create_test_scheme
    
    # 完了メッセージ
    echo ""
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN} ✅ UIテストの生成が完了しました！${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}次のステップ:${NC}"
    echo ""
    echo "1. Xcodeでプロジェクトを開く"
    echo "2. $UI_TEST_DIR をプロジェクトに追加"
    echo "3. UITestsターゲットのBuild Phasesで:"
    echo "   - SnapshotHelper.swift を追加"
    echo "   - ScreenshotUITests.swift を追加"
    echo ""
    echo "4. スクリーンショットを撮影:"
    echo "   ${YELLOW}./deploy.sh screenshots${NC}"
    echo ""
    echo -e "${PURPLE}ヒント:${NC}"
    echo "• 生成されたテストをカスタマイズして、アプリ固有の画面を追加"
    echo "• snapshot(\"画面名\") でスクリーンショットポイントを追加"
    echo "• 各言語でのテストは自動的に実行されます"
}

# 実行
main