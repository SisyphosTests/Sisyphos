public struct Button: PageElement {
    public let elementIdentifier: PageElementIdentifier

    let label: String?
    let identifier: String?

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .button,
            identifier: identifier,
            label: label,
            value: nil,
            descendants: []
        )
    }

    public init(
        identifier: String? = nil,
        label: String? = nil,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.label = label
        self.identifier = identifier
    }
}
