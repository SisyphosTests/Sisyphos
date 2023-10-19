public struct Other: PageElement {
    public let elementIdentifier: PageElementIdentifier

    let identifier: String?
    let label: String?

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .other,
            identifier: identifier,
            label: label,
            value: nil,
            descendants: []
        )
    }

    public init(
        label: String,
        identifier: String? = nil,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.label = label
    }

    public init(
        identifier: String,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.label = nil
    }
}
