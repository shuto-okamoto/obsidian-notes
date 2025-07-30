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
