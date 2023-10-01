import XCTest
import SwiftUI
import Sisyphos


final class CollectionViewTests: XCTestCase {
    func testCollectionView() {
        launchTestApp {
            List {
                Text("First Cell")
                Group {
                    Text("Second Cell")
                    Text("Still Second Cell")
                }
                SwiftUI.Button("Third Cell", action: {})
            }
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                CollectionView {
                    Cell {
                        StaticText("First Cell")
                    }
                    Cell {
                        StaticText("Second Cell")
                        StaticText("Still Second Cell")
                    }
                    Cell {
                        Sisyphos.Button(label: "Third Cell")
                    }
                }
            }
        }
    }
}
