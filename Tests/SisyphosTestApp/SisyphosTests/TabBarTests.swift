import XCTest
import Sisyphos
import SwiftUI


final class TabBarTests: XCTestCase {

    func testTabBar() {
        launchTestApp(swiftUI: {
            TabView {
                Text("First Screen")
                    .tabItem {
                        Text("First")
                    }
                Text("Second Screen")
                    .tabItem {
                        Text("Second")
                    }
            }
        })

        struct ExpectedPage: Page {
            var body: PageDescription {
                StaticText("First Screen")
                TabBar {
                    Button(label: "First")
                    Button(label: "Second")
                }
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testTabBarInteraction() {
        launchTestApp(swiftUI: {
            TabView {
                Text("First Screen")
                    .tabItem {
                        Text("First")
                    }
                Text("Second Screen")
                    .tabItem {
                        Text("Second")
                    }
            }
        })

        struct FirstPage: Page {
            let firstTab = Button(label: "First")
            let secondTab = Button(label: "Second")

            var body: PageDescription {
                StaticText("First Screen")
                TabBar {
                    firstTab
                    secondTab
                }
            }
        }
        struct SecondPage: Page {
            let firstTab = Button(label: "First")
            let secondTab = Button(label: "Second")

            var body: PageDescription {
                StaticText("Second Screen")
                TabBar {
                    firstTab
                    secondTab
                }
            }
        }
        let firstPage = FirstPage()
        firstPage.waitForExistence()
        firstPage.secondTab.tap()
        let secondPage = SecondPage()
        secondPage.waitForExistence()
        secondPage.firstTab.tap()
        firstPage.waitForExistence()
    }
}
