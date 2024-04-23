public struct Other: PageElement, HasChildren {
    public let elementIdentifier: PageElementIdentifier

    let identifier: String?
    let label: String?
    let elements: [any PageElement]

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .other,
            identifier: identifier,
            label: label,
            value: nil,
            descendants: elements.map { $0.queryIdentifier }
        )
    }

    init(identifier: String?, label: String?, elements: [PageElement]) {
        self.elementIdentifier = .dynamic
        self.label = label
        self.identifier = identifier
        self.elements = elements
    }

    public init(
        identifier: String? = nil,
        label: String,
        @PageBuilder children: () -> PageDescription = PageBuilder.empty,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.label = label
        self.elements = children().elements
    }

    public init(
        identifier: String,
        @PageBuilder children: () -> PageDescription = PageBuilder.empty,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.label = nil
        self.elements = children().elements
    }
}
