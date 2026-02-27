import XCTest

public struct WebView: PageElement, HasChildren {
    public let elementIdentifier: PageElementIdentifier
    let identifier: String?
    public let elements: [PageElement]

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .webView,
            identifier: identifier,
            label: nil,
            value: nil,
            descendants: elements.map { $0.queryIdentifier }
        )
    }

    init(identifier: String?, elements: [PageElement]) {
        self.elementIdentifier = .dynamic
        self.identifier = identifier
        self.elements = elements
    }

    public init(
        identifier: String? = nil,
        @PageBuilder children: () -> PageDescription = PageBuilder.empty,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.elements = children().elements
    }
}
