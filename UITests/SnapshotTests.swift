import XCTest

@MainActor
final class SnapshotTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-SNAPSHOT_DEMO"]
        setupSnapshot(app)
        app.launch()
    }

    // With demo data seeded, the app launches into an active game on the Score tab.

    func testScoreTab() {
        snapshot("01_Score")
    }

    func testPlayersTab() {
        app.buttons["Players"].tap()
        snapshot("02_Players")
    }

    func testFeedTab() {
        app.buttons["Feed"].tap()
        snapshot("03_Feed")
    }

    func testRulesTab() {
        app.buttons["Rules"].tap()
        snapshot("04_Rules")
    }

    func testNewGameSheet() {
        // Tap the "+" button in the game header
        app.buttons["plus.circle"].tap()
        snapshot("05_NewGame")
    }
}

@MainActor
final class WinnerSnapshotTests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["-SNAPSHOT_WINNER"]
        setupSnapshot(app)
        app.launch()
    }

    func testWinnerScreen() {
        // Wait for confetti overlay to appear
        let winnerText = app.staticTexts["WINNER!"]
        XCTAssertTrue(winnerText.waitForExistence(timeout: 3))
        snapshot("06_Winner")
    }
}
