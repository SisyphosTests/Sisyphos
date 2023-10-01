import XCTest
import SwiftUI
import Sisyphos


final class SwitchTests: XCTestCase {
    func testSwitchThatHasOnlyLabelIdentifiedByLabel() {
        launchTestApp {
            Toggle("Some Toggle", isOn: binding(initialValue: false))
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                Switch(label: "Some Toggle")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testSwitchThatHasOnlyIdentifierIdentifiedByIdentifier() {
        launchTestApp {
            Toggle("", isOn: binding(initialValue: false))
                .accessibilityIdentifier("the_switch")
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                Switch(identifier: "the_switch")
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }
}
