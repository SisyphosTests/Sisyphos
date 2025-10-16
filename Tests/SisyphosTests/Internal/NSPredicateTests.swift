import XCTest
@testable import Sisyphos


final class NSPredicateTests: XCTestCase {
    func testPredicateDescription() {
        let predicate = NSPredicate(format: "%@ > 42")
        let sisyphosPredicate = NSPredicate(
            snapshot: FakeSnapshot()
        )

        XCTAssertTrue(predicate.description.starts(with: "<NSComparisonPredicate:"))
        XCTAssertEqual(
            "{element=alert, identifier=\"expected identifier\", label=\"expected label\", value=\"expected value\"}",
            sisyphosPredicate.description
        )
    }
}


/// We can't get an instance of an actual XCUIElementSnapshot because we are running unit tests and not UI tests.
/// But this fake is good enough for testing our NSPredicate logic.
private class FakeSnapshot: XCUIElementSnapshot {
    var children: [any XCUIElementSnapshot] = []
    var dictionaryRepresentation: [XCUIElement.AttributeName : Any] = [:]
    var identifier: String = "expected identifier"
    var frame: CGRect = .zero
    var value: Any? = "expected value"
    var title: String = "title"
    var label: String = "expected label"
    var elementType: XCUIElement.ElementType = .alert
    var isEnabled: Bool = false
    var horizontalSizeClass: XCUIElement.SizeClass = .compact
    var verticalSizeClass: XCUIElement.SizeClass = .compact
    var placeholderValue: String? = nil
    var isSelected: Bool = false
    var hasFocus: Bool = false
}
