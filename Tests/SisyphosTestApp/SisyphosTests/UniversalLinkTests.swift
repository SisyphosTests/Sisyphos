import XCTest
import SwiftUI
@testable import Sisyphos


@MainActor
final class UniversalLinkTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testUniversalLink() {
        let mapsApp = XCUIApplication(bundleIdentifier: "com.apple.Maps")
        mapsApp.terminate()

        open(universalLink: "https://maps.apple.com/?q=Cupertino")
        // First launch of Maps in a fresh simulator shows the location permissions dialogue.
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        if springboard.state == .runningForeground {
            let permissionButton = springboard.buttons["Don’t Allow".localizedForSimulator]
            if permissionButton.waitForExistence(timeout: 2) {
                permissionButton.tap()
            }
        }

        XCTAssertTrue(mapsApp.state == .runningForeground)

        // And run a second time to check that the keyboard input works a second time.
        mapsApp.terminate()

        open(universalLink: "https://maps.apple.com/?q=Cupertino")

        XCTAssertTrue(mapsApp.state == .runningForeground)
    }
}
