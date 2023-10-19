public struct StaticText: PageElement {
    public let elementIdentifier: PageElementIdentifier

    let identifier: String?
    let text: String?

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .staticText,
            identifier: nil,
            label: text,
            value: nil,
            descendants: []
        )
    }

    public init(
        identifier: String? = nil,
        _ text: String,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.text = text
    }

    public init(
        identifier: String,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ){
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.text = nil
    }
}
