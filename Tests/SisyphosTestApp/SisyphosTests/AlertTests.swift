import XCTest
import SwiftUI
import Sisyphos


final class AlertTests: XCTestCase {
    func testAlertIdentifierByChildren() {
        launchTestApp {
            Text("App")
            .alert(
                "Some Alert",
                isPresented: binding(initialValue: true),
                actions: {
                    Button(action: {}) { Text("OK") }
                },
                message: {
                    Text("This is some alert.")
                }
            )
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                Alert {
                    StaticText("Some Alert")
                    StaticText("This is some alert.")
                }
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }
}
