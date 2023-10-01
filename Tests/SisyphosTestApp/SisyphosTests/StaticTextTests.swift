import XCTest
import SwiftUI
import Sisyphos


final class StaticTextTests: XCTestCase {
    func testStaticText() {
        launchTestApp {
            Text("Hello")
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                StaticText("Hello")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testStaticTextAdditionallyIdentifiedByIdentifier() {
        launchTestApp {
            Text("Hello")
                .accessibilityIdentifier("the_text")
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                StaticText(identifier: "the_text", "Hello")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }
}
