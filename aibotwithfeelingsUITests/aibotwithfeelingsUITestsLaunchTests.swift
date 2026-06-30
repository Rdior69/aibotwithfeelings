//
//  aibotwithfeelingsUITestsLaunchTests.swift
//  aibotwithfeelingsUITests
//
//  Created by ray dior on 5/29/26.
//

import XCTest

final class aibotwithfeelingsUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--uitest-seed-profile"]
        app.launch()

        XCTAssertTrue(app.staticTexts["chat.title"].waitForExistence(timeout: 2))

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
