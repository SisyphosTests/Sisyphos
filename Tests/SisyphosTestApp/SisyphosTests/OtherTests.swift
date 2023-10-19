import XCTest
import SwiftUI
@testable import Sisyphos


final class OtherTests: XCTestCase {
    func testOtherElementCapturedWithIdentifier() {
        launchTestApp {
            Color.green
                .frame(width: 100, height: 100, alignment: .center)
                .accessibilityIdentifier("Identifier")
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                Other(identifier: "Identifier")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testOtherElementCapturedWithLabel() {
        launchTestApp {
            Color.green
                .frame(width: 100, height: 100, alignment: .center)
                .accessibilityLabel("Label")
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                Other(label: "Label")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testOtherElementCapturedWithBothLabelAndIdentifier() {
        launchTestApp {
            Color.green
                .frame(width: 100, height: 100, alignment: .center)
                .accessibilityLabel("Label")
                .accessibilityIdentifier("Identifier")
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                Other(label: "Label", identifier: "Identifier")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }
}
