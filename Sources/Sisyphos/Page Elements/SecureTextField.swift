public struct SecureTextField: PageElement {
    public let elementIdentifier: PageElementIdentifier

    public let identifier: String?

    public let value: String?

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
            elementType: .secureTextField,
            identifier: identifier,
            label: nil,
            value: value,
            descendants: []
        )
    }
}
