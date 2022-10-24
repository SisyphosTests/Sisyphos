import XCTest

public struct QueryIdentifier {
    let elementType: XCUIElement.ElementType
    let identifier: String?
    let label: String?
    let value: String?
    let descendants: [QueryIdentifier]
}
