import XCTest
import SwiftUI
import Sisyphos


final class TextFieldTests: XCTestCase {

    func testTextFieldWithValueAndIdentifierIdentifiedByIdentifier() {
        launchTestApp {
            SwiftUI.TextField("Enter text", text: appValueBinding())
                .accessibilityIdentifier("the_textfield")
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                Sisyphos.TextField(identifier: "the_textfield")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testTextFieldWithValueAndIdentifierIdentifiedByValue() {
        launchTestApp {
            SwiftUI.TextField("Enter text", text: binding(initialValue: "Some Value"))
                .accessibilityIdentifier("the_textfield")
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                Sisyphos.TextField(value: "Some Value")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testTextFieldWithValueAndIdentifierIdentifiedByTypeOnly() {
        launchTestApp {
            Text("Some Text")
            SwiftUI.TextField("Enter text", text: appValueBinding())
                .accessibilityIdentifier("the_textfield")
            Button("Some button", action: {})
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                Sisyphos.TextField()
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testTextFieldInteractionTypeText() {
        let app = launchTestApp {
            SwiftUI.TextField("Enter text", text: appValueBinding())
        }

        struct ExpectedPage: Page {
            let textField = Sisyphos.TextField()

            var body: PageDescription {
                textField
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
        expectedPage.textField.type(text: "Hello from test")

        XCTAssertEqual(app.label, "Hello from test")
        XCTAssertEqual(app.textFields.firstMatch.value as? String, "Hello from test")
    }

    func testTextFieldInteractionTap() {
        let app = launchTestApp {
            SwiftUI.TextField("Enter text", text: appValueBinding())
        }
        struct ExpectedPage: Page {
            let textField = Sisyphos.TextField()

            var body: PageDescription {
                textField
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()

        XCTAssertFalse(app.textFields.firstMatch.hasKeyboardFocus)
        expectedPage.textField.tap()
        XCTAssertTrue(app.textFields.firstMatch.hasKeyboardFocus)
    }
}


extension XCUIElement {
    var hasKeyboardFocus: Bool {
        value(forKey: "hasKeyboardFocus") as? Bool ?? false
    }
}
