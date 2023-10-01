import XCTest
import SwiftUI
import Sisyphos


final class TestDataTests: XCTestCase {
    func testTestDataExtractsValueFromStaticText() {
        launchTestApp {
            Text("Test: Some Value")
        }

        struct ExpectedPage: Page {
            @TestData var value: String

            var body: PageDescription {
                StaticText("Test: \(value)")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()

        XCTAssertEqual(expectedPage.value, "Some Value")
    }

    func testTestDataExtractsValueFromButton() {
        launchTestApp {
            SwiftUI.Button("Buy now for 7.77 EUR", action: {})
        }

        struct ExpectedPage: Page {
            @TestData var price: String

            var body: PageDescription {
                Button(label: "Buy now for \(price)")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()

        XCTAssertEqual(expectedPage.price, "7.77 EUR")
    }
}
