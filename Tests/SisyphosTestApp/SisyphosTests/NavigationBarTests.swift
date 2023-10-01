import XCTest
import SwiftUI
import Sisyphos


final class NavigationBarTests: XCTestCase {

    func testNavigationBarIdentifiedWithContents() {
        launchTestApp {
            NavigationStack {
                Text("Welcome!")
                    .navigationTitle("Hello NavigationBar!")
            }
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                NavigationBar {
                    StaticText("Hello NavigationBar!")
                }
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testNavigationBarInteraction() {
        launchTestApp {
            NavigationStack(path: binding(initialValue: [1, 2, 3, 4])) {
                Group {
                    Text("Initial Page")
                    NavigationLink("Let's start", value: 1)
                }
                .navigationTitle("Start")
                    .navigationDestination(for: Int.self) { number in
                        Text("Page \(number)")
                            .navigationTitle("Page \(number)")
                        NavigationLink("next page", value: number + 1)
                    }
            }
        }

        struct ExpectedPage4: Page {
            let backButton = Sisyphos.Button(label: "Page 3")
            var body: PageDescription {
                NavigationBar {
                    backButton
                    StaticText("Page 4")
                }
            }
        }
        let expectedPage4 = ExpectedPage4()
        expectedPage4.waitForExistence()
        expectedPage4.backButton.tap()

        struct ExpectedPage3: Page {
            let backButton = Sisyphos.Button(label: "Page 2")
            var body: PageDescription {
                NavigationBar {
                    backButton
                    StaticText("Page 3")
                }
            }
        }
        let expectedPage3 = ExpectedPage3()
        expectedPage3.waitForExistence()
    }
}
