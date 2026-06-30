//
//  aibotwithfeelingsUITests.swift
//  aibotwithfeelingsUITests
//
//  Created by ray dior on 5/29/26.
//

import XCTest

final class aibotwithfeelingsUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
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
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
