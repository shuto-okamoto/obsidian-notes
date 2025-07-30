import XCTest

class ObsidianNotesUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    func testObsidianNotesScreenshots() throws {
        let app = XCUIApplication()
        
        // メイン画面のスクリーンショット
        // アプリが完全に読み込まれるまで待機
        sleep(3)
        snapshot("01_MainScreen")
        
        // Newボタンをタップしてメモ作成画面に移動
        let newButton = app.buttons["New"]
        if newButton.exists {
            newButton.tap()
            sleep(2)
            snapshot("02_NewMemo")
            
            // メモにテキストを入力（もしテキストフィールドがあれば）
            let textEditor = app.textViews.firstMatch
            if textEditor.exists {
                textEditor.tap()
                textEditor.typeText("これは美しいObsidian風メモアプリのデモです。\n\n• ダークテーマ\n• クリスタルデザイン\n• 高速検索\n• 複数テーマ")
                sleep(1)
                snapshot("03_MemoEditing")
            }
            
            // 戻るボタンまたは保存ボタンを探す
            let backButton = app.navigationBars.buttons.firstMatch
            if backButton.exists {
                backButton.tap()
                sleep(1)
            }
        }
        
        // 検索バーをテスト
        let searchField = app.textFields["Search memos..."]
        if searchField.exists {
            searchField.tap()
            searchField.typeText("デモ")
            sleep(1)
            snapshot("04_Search")
            
            // 検索をクリア
            searchField.clearText()
        }
        
        // テーマ選択ボタンをテスト（もしあれば）
        let themeButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'theme'"))
        if themeButtons.count > 0 {
            themeButtons.firstMatch.tap()
            sleep(1)
            snapshot("05_ThemeSelector")
            
            // テーマを変更してスクリーンショット
            let colorButtons = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'color'"))
            if colorButtons.count > 1 {
                colorButtons.element(boundBy: 1).tap()
                sleep(1)
                snapshot("06_BlueTheme")
            }
        }
        
        // メモリスト全体のスクリーンショット
        snapshot("07_MemoList")
    }
    
    func testDifferentThemes() throws {
        let app = XCUIApplication()
        
        // 各テーマでのスクリーンショット
        let themes = ["Purple", "Blue", "Green", "Orange"]
        
        for (index, theme) in themes.enumerated() {
            // テーマ切り替えロジック（実装に依存）
            let themeButton = app.buttons.containing(NSPredicate(format: "label CONTAINS '\(theme)'")).firstMatch
            if themeButton.exists {
                themeButton.tap()
                sleep(1)
                snapshot("08_\(theme)Theme_\(index + 1)")
            }
        }
    }
    
    func testEmptyState() throws {
        let app = XCUIApplication()
        
        // 空の状態をテスト（メモが何もない場合）
        // ウェルカムメッセージや空状態の画面
        if app.staticTexts["Ready to capture your thoughts"].exists {
            snapshot("09_WelcomeScreen")
        }
    }
    
    func testAppIcon() throws {
        let app = XCUIApplication()
        
        // アプリアイコンエリアのスクリーンショット
        if app.images.firstMatch.exists {
            snapshot("10_AppIcon")
        }
    }
}

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }
        
        let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
        self.typeText(deleteString)
    }
}

extension XCUIElement {
    func tapIfExists() {
        if self.exists {
            self.tap()
        }
    }
    
    func waitForExistence(timeout: TimeInterval = 5) -> Bool {
        return self.waitForExistence(timeout: timeout)
    }
}