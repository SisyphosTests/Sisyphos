import XCTest
import SwiftUI
import Sisyphos


final class PageExistsErrorTests: XCTestCase {
    func testMissingElementAbove() {
        launchTestApp {
            Text("Text")
        }

        struct NotExpectedPage: Page {
            var body: PageDescription {
                Button(label: "Button")
                StaticText("Text")
            }
        }
        XCTExpectFailure(options: createAssertionOptions(missingElement: "Button", definedAtOffset: -4, column: 23))
        let notExpectedPage = NotExpectedPage()
        notExpectedPage.waitForExistence(timeout: 1)
    }

    func testMissingElementBelow() {
        launchTestApp {
            Text("Text")
        }

        struct NotExpectedPage: Page {
            var body: PageDescription {
                StaticText("Text")
                Button(label: "Button")
            }
        }
        XCTExpectFailure(options: createAssertionOptions(missingElement: "Button", definedAtOffset: -3, column: 23))
        let notExpectedPage = NotExpectedPage()
        notExpectedPage.waitForExistence(timeout: 1)
    }
}


private func createAssertionOptions(
    missingElement: String,
    definedAtOffset lineOffset: Int,
    column: UInt,
    file: StaticString = #file,
    line: UInt = #line
) -> XCTExpectedFailure.Options {
    let expectedLine: UInt
    if lineOffset > 0 {
        expectedLine = line + UInt(lineOffset)
    } else {
        expectedLine = line - UInt(abs(lineOffset))
    }
    let expectedText = "failed - Page NotExpectedPage didn\'t exist after 1.0s\n⛔️ missing element \(missingElement), defined at \(file) \(expectedLine):\(column)"
    let options = XCTExpectedFailure.Options()
    options.issueMatcher = { issue in
        return issue.type == .assertionFailure
        && issue.compactDescription == expectedText
    }
    return options
}
