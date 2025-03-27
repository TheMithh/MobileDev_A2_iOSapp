//
//  A2_iOS_GabrielPais_101271055UITestsLaunchTests.swift
//  A2_iOS_GabrielPais_101271055UITests
//
//  Created by viorel pais on 2025-03-27.
//

import XCTest

final class A2_iOS_GabrielPais_101271055UITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
