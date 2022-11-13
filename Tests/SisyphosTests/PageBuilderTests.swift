import XCTest
import Sisyphos


final class PageBuilderTests: XCTestCase {

    func page(@PageBuilder page: () -> PageDescription) -> PageDescription {
        page()
    }

    func testConditionals() {
        func createPage(condition: Bool) -> PageDescription {
            page {
                StaticText("First Element")
                if condition {
                    TextField()
                    StaticText("Third Element")
                }
            }
        }

        let firstPage = createPage(condition: false)
        XCTAssertEqual(firstPage.elements.count, 1)
        XCTAssertTrue(firstPage.elements.first is StaticText)


        let secondPage = createPage(condition: true)
        XCTAssertEqual(secondPage.elements.count, 3)
        XCTAssertTrue(secondPage.elements[0] is StaticText)
        XCTAssertTrue(secondPage.elements[1] is TextField)
        XCTAssertTrue(secondPage.elements[2] is StaticText)
    }

    func testNavigationBar() throws {
        let page = page {
            NavigationBar {
                StaticText("First Element")
                TextField()
            }
        }

        XCTAssertEqual(page.elements.count, 1)
        let navBar = try XCTUnwrap(page.elements.first as? NavigationBar)
        XCTAssertEqual(navBar.elements.count, 2)
        XCTAssertTrue(navBar.elements[0] is StaticText)
        XCTAssertTrue(navBar.elements[1] is TextField)
    }
}
