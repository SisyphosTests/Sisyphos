import XCTest
import SwiftUI
import Sisyphos


final class ButtonTests: XCTestCase {
    func testButtonThatHasIdentifierWithLabelIdentifyByIdentifier() {
        launchTestApp(swiftUI: {
            SwiftUI.Button(action: {}) {
                Text("Some Button")
            }
            .accessibilityIdentifier("some_button")
        })

        struct ExpectedPage: Page {
            var body: PageDescription {
                Sisyphos.Button(identifier: "some_button")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testButtonThatHasIdentifierWithLabelIdentifyByLabel() {
        launchTestApp(swiftUI: {
            SwiftUI.Button(action: {}) {
                Text("Some Button")
            }
            .accessibilityIdentifier("some_button")
        })

        struct ExpectedPage: Page {
            var body: PageDescription {
                Sisyphos.Button(label: "Some Button")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testButtonThatHasIdentifierWithLabelIdentifyByLabelAndIdentifier() {
        launchTestApp(swiftUI: {
            SwiftUI.Button(action: {}) {
                Text("Some Button")
            }
            .accessibilityIdentifier("some_button")
        })

        struct ExpectedPage: Page {
            var body: PageDescription {
                Sisyphos.Button(identifier: "some_button", label: "Some Button")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testButtonInteractionTap() {
        let app = launchTestApp(swiftUI: {
            SwiftUI.Button(action: {
                UIApplication.shared.accessibilityLabel = "Button tapped"
            }) {
                Text("Some Button")
            }
            .accessibilityIdentifier("some_button")

            SwiftUI.Button(action: {}) {
                Text("Button that should not be matched")
            }
        })

        struct ExpectedPage: Page {
            let button = Sisyphos.Button(identifier: "some_button")

            var body: PageDescription {
                button
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()

        expectedPage.button.tap()
        XCTAssertEqual(app.label, "Button tapped")
    }
}
