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
    func testOnboardingAndChatFlow() throws {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TEST_RESET"]
        app.launch()

        let nameField = app.textFields["onboardingNameField"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 5))
        nameField.tap()
        nameField.typeText("Test User")

        app.buttons["onboardingContinueButton"].tap()
        app.buttons["onboardingStartButton"].tap()

        let chatTab = app.tabBars.buttons["Chat"]
        XCTAssertTrue(chatTab.waitForExistence(timeout: 5))

        let input = app.textFields["chatInputField"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.tap()
        input.typeText("I feel happy today")
        app.buttons["sendMessageButton"].tap()

        XCTAssertTrue(app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] 'happy'")).firstMatch.waitForExistence(timeout: 5))
    }
}
