import XCTest
import SwiftUI
import Sisyphos


final class SecureTextFieldTests: XCTestCase {
    func testSecureTextFieldIdentifiedByType() {
        launchTestApp {
            SecureField("Enter password", text: binding(initialValue: ""))
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                SecureTextField()
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testSecureTextFieldIdentifiedByIdentifier() {
        launchTestApp {
            SecureField("Enter password", text: binding(initialValue: ""))
                .accessibilityIdentifier("the_securefield")
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                SecureTextField(identifier: "the_securefield")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }
}
