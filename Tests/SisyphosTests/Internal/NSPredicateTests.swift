import XCTest
@testable import Sisyphos


final class NSPredicateTests: XCTestCase {
    func testPredicateDescription() {
        let predicate = NSPredicate(format: "%@ > 42")
        let sisyphosPredicate = NSPredicate(
            step: .init(
                elementType: .alert,
                identifier: "expected identifier",
                label: "expected label",
                value: "expected value"
            )
        )

        XCTAssertTrue(predicate.description.starts(with: "<NSComparisonPredicate:"))
        XCTAssertEqual(
            "{element=alert, identifier=\"expected identifier\", label=\"expected label\", value=\"expected value\"}",
            sisyphosPredicate.description
        )
    }
}
