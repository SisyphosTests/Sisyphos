public struct Alert: PageElement, HasChildren {

    public let elementIdentifier: PageElementIdentifier

    public let identifier: String?

    public let elements: [PageElement]

    public init(
        identifier: String? = nil,
        @PageBuilder children: () -> PageDescription,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.elements = children().elements
    }

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .alert,
            identifier: identifier,
            label: nil,
            value: nil,
            descendants: []
        )
    }
}
