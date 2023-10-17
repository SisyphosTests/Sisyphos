public struct BrazeOverlay: PageElement {
    public let elementIdentifier: PageElementIdentifier

    let label: String
    let identifier: String?

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
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.label = "Appboy Slideup"
        self.identifier = nil
    }
}
