import XCTest
import SwiftUI
import Sisyphos


final class ScrollTests: XCTestCase {
    func testScrollDownUntilVisible() {
        launchTestApp {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(1..<50, id: \.self) { number in
                        Text("Item \(number)")
                            .frame(maxWidth: .infinity, minHeight: 100)
                    }
                }
            }
        }

        struct ExpectedPage: Page {
            let targetElement = StaticText("Item 23")

            var body: PageDescription {
                targetElement
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
        expectedPage.targetElement.scrollUntilVisibleOnScreen(direction: .down)
    }
}
