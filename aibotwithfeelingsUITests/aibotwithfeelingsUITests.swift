//
//  aibotwithfeelingsUITests.swift
//  aibotwithfeelingsUITests
//
//  Created by ray dior on 5/29/26.
//

import XCTest

final class aibotwithfeelingsUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitest-reset-profile"]
        app.launch()

        let nameField = app.textFields["onboarding.nameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Ray")

        app.buttons["onboarding.startButton"].tap()
        XCTAssertTrue(app.staticTexts["chat.title"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.textFields["chat.composerField"].exists)
    }

    @MainActor
    func testSettingsButtonOpensSheet() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitest-seed-profile"]
        app.launch()

        let settingsButton = app.buttons["chat.settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 2))
        settingsButton.tap()

        XCTAssertTrue(app.navigationBars["Settings"].waitForExistence(timeout: 2))
        app.buttons["Close"].tap()
        XCTAssertFalse(app.navigationBars["Settings"].exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
