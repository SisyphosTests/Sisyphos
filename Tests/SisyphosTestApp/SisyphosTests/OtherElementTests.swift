import XCTest
import SwiftUI
import Sisyphos


final class OtherElementTests: XCTestCase {
    func testOtherElementCaptured() {
        launchTestApp {
            Color.green
                .frame(width: 100, height: 100, alignment: .center)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("Identifier")
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                OtherElement(identifier: "Identifier")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }
}
