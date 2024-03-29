public struct Switch: PageElement {
    public let elementIdentifier: PageElementIdentifier

    let identifier: String?
    let label: String?

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .switch,
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
        self.identifier = identifier
        self.label = label
    }
}
