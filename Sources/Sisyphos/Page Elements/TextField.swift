import XCTest


public struct TextField: PageElement {
    public let elementIdentifier: PageElementIdentifier

    public let identifier: String?

    @Shared public var value: String?

    public init(
        identifier: String? = nil,
        value: String? = nil,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.value = value
        self.identifier = identifier
    }

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .textField,
            identifier: identifier,
            label: nil,
            value: value,
            descendants: []
        )
    }

    public func type(text: String, dismissKeyboard: Bool = true) {
        XCTContext.runActivity(named: "Typing text \(text.debugDescription)") { activity in
            guard let element = getXCUIElement(forAction: "type(text: \(text.debugDescription)") else { return }
            element.waitUntilStablePosition()
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            element.typeText(text)

            self.value = element.value as? String

            guard dismissKeyboard else { return }
            guard let application = getPage()?.xcuiapplication else {
                assertionFailure()
                return
            }
            application.dismissKeyboard()
        }
    }
}
