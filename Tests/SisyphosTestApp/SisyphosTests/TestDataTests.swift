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

    func testTestDataExtractsMultipleValuesFromStaticText() {
        launchTestApp {
            Text("Order: 3 items for 9.99 EUR")
        }

        struct ExpectedPage: Page {
            @TestData var quantity: String
            @TestData var price: String

            var body: PageDescription {
                StaticText("Order: \(quantity) items for \(price) EUR")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()

        XCTAssertEqual(expectedPage.quantity, "3")
        XCTAssertEqual(expectedPage.price, "9.99")
    }

    func testTestDataExtractsThreeValuesFromStaticText() {
        launchTestApp {
            Text("Ship Red-42 to Mars")
        }

        struct ExpectedPage: Page {
            @TestData var action: String
            @TestData var item: String
            @TestData var destination: String

            var body: PageDescription {
                StaticText("\(action) \(item) to \(destination)")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()

        XCTAssertEqual(expectedPage.action, "Ship")
        XCTAssertEqual(expectedPage.item, "Red-42")
        XCTAssertEqual(expectedPage.destination, "Mars")
    }

    func testTestDataNonMatchingPageDoesNotExist() {
        launchTestApp {
            Text("Hello World")
        }

        struct NotExpectedPage: Page {
            @TestData var value: String

            var body: PageDescription {
                StaticText("Goodbye \(value)")
            }
        }
        XCTExpectFailure("The page label does not match the app content")
        let notExpectedPage = NotExpectedPage()
        notExpectedPage.waitForExistence(timeout: 1)
    }
}
