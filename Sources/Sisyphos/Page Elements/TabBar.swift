public struct TabBar: PageElement, HasChildren {
    public let elementIdentifier: PageElementIdentifier

    public let elements: [PageElement]

    init(elements: [PageElement]) {
        self.elementIdentifier = .dynamic
        self.elements = elements
    }

    public init(
        @PageBuilder elements: () -> PageDescription,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.elements = elements().elements
    }

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .tabBar,
            identifier: nil,
            label: nil,
            value: nil,
            descendants: elements.map { $0.queryIdentifier }
        )
    }
}
