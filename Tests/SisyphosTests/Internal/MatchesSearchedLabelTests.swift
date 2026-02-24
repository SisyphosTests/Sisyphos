import XCTest
@testable import Sisyphos


final class MatchesSearchedLabelTests: XCTestCase {

    // MARK: - Multi-variable extraction

    func testSingleVariableExtraction() {
        let id = UUID()
        let label = "Hello {\(id.uuidString)} World"

        let result = "Hello Foo World".matches(searchedLabel: label)

        XCTAssertTrue(result)
        XCTAssertEqual(TestData[id], "Foo")
    }

    func testMultipleVariableExtraction() {
        let id1 = UUID()
        let id2 = UUID()
        let label = "{\(id1.uuidString)} and {\(id2.uuidString)}"

        let result = "first and second".matches(searchedLabel: label)

        XCTAssertTrue(result)
        XCTAssertEqual(TestData[id1], "first")
        XCTAssertEqual(TestData[id2], "second")
    }

    func testThreeVariableExtraction() {
        let id1 = UUID()
        let id2 = UUID()
        let id3 = UUID()
        let label = "{\(id1.uuidString)}-{\(id2.uuidString)}-{\(id3.uuidString)}"

        let result = "a-b-c".matches(searchedLabel: label)

        XCTAssertTrue(result)
        XCTAssertEqual(TestData[id1], "a")
        XCTAssertEqual(TestData[id2], "b")
        XCTAssertEqual(TestData[id3], "c")
    }

    // MARK: - Non-matching labels return false

    func testNonMatchingStringReturnsFalse() {
        let id = UUID()
        let label = "Expected: {\(id.uuidString)}"

        let result = "Something else entirely".matches(searchedLabel: label)

        XCTAssertFalse(result)
        XCTAssertNil(TestData[id])
    }

    func testNonMatchingMultiVariableReturnsFalse() {
        let id1 = UUID()
        let id2 = UUID()
        let label = "{\(id1.uuidString)} and {\(id2.uuidString)}"

        let result = "no separator here".matches(searchedLabel: label)

        XCTAssertFalse(result)
        XCTAssertNil(TestData[id1])
        XCTAssertNil(TestData[id2])
    }

    // MARK: - Labels without variables

    func testExactMatchWithoutVariables() {
        XCTAssertTrue("Hello".matches(searchedLabel: "Hello"))
    }

    func testMismatchWithoutVariables() {
        XCTAssertFalse("Hello".matches(searchedLabel: "World"))
    }
}
