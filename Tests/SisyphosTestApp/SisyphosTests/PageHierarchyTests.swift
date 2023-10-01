import XCTest
import SwiftUI
import Sisyphos


final class PageHierarchyTests: XCTestCase {
    func testComplexHierarchy() {
        launchTestApp {
            TabView {
                NavigationStack {
                    Text("First Text")
                    Button(action: {}) {
                        Text("Button")
                    }.padding()
                    Text("Second Text")
                    List([1, 2, 3, 4], id: \.self) { number in
                        Text("\(number)")
                    }
                    .navigationTitle("Test App")
                }
                .tabItem {
                    Text("First Tab")
                }

                Text("Second Page")
                    .tabItem {
                        Text("Second Tab")
                    }
            }
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                NavigationBar {
                    StaticText("Test App")
                }
                StaticText("First Text")
                Button(label: "Button")
                StaticText("Second Text")
                CollectionView {
                    Cell {
                        StaticText("1")
                    }
                    Cell {
                        StaticText("2")
                    }
                    Cell {
                        StaticText("3")
                    }
                    Cell {
                        StaticText("4")
                    }
                }
                TabBar {
                    Button(label: "First Tab")
                    Button(label: "Second Tab")
                }
            }

        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testHierarchyWithOmmittedElements() {
        launchTestApp {
            TabView {
                NavigationStack {
                    Text("First Text")
                    Button(action: {}) {
                        Text("Button")
                    }.padding()
                    Text("Second Text")
                    List([1, 2, 3, 4], id: \.self) { number in
                        Text("\(number)")
                    }
                    .navigationTitle("Test App")
                }
                .tabItem {
                    Text("First Tab")
                }

                Text("Second Page")
                    .tabItem {
                        Text("Second Tab")
                    }
            }
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                NavigationBar {
                    StaticText("Test App")
                }
                CollectionView {
                    Cell {
                        StaticText("3")
                    }
                }
            }

        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
    }

    func testConditionals() {
        launchTestApp {
            Text("First Text")
        }

        struct ExpectedPage: Page {
            var isSomeVariable = false
            var body: PageDescription {
                StaticText("First Text")
                if isSomeVariable {
                    StaticText("Conditional Second Text")
                }
            }
        }
        var expectedPage = ExpectedPage()
        expectedPage.waitForExistence()

        expectedPage.isSomeVariable = true
        XCTAssertFalse(expectedPage.exists().isExisting)

        launchTestApp {
            Text("First Text")
            Text("Conditional Second Text")
        }
        expectedPage.waitForExistence()
    }

    func testOptionals() {
        launchTestApp {
            Text("First Text")
        }

        struct ExpectedPage: Page {
            var maybeElement: StaticText?

            var body: PageDescription {
                StaticText("First Text")
                maybeElement
            }
        }
        var expectedPage = ExpectedPage()
        expectedPage.waitForExistence()

        expectedPage.maybeElement = StaticText("Second Text")
        XCTAssertFalse(expectedPage.exists().isExisting)

        launchTestApp {
            Text("First Text")
            Text("Second Text")
        }

        expectedPage.waitForExistence()
    }

    func testIfElse() {
        launchTestApp {
            Text("First Text")
            Text("Second Text")
        }

        struct ExpectedPage: Page {
            var isAlternative = false

            var body: PageDescription {
                StaticText("First Text")
                if isAlternative {
                    StaticText("Alternative Second Text")
                } else {
                    StaticText("Second Text")
                }
            }
        }
        var expectedPage = ExpectedPage()
        expectedPage.waitForExistence()

        launchTestApp {
            Text("First Text")
            Text("Alternative Second Text")
        }

        expectedPage.isAlternative = true
        expectedPage.waitForExistence()
    }
}
