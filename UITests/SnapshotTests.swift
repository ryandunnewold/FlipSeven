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

    func testHistoryTab() {
        app.buttons["History"].tap()
        snapshot("02_History")
    }

    func testRulesTab() {
        app.buttons["Rules"].tap()
        snapshot("03_Rules")
    }

    func testSettingsTab() {
        app.buttons["Settings"].tap()
        snapshot("04_Settings")
    }

    func testNewGameSheet() {
        app.buttons["New Game"].tap()
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
