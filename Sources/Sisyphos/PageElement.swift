import XCTest


public protocol PageElement {
    var elementIdentifier: PageElementIdentifier { get }

    var queryIdentifier: QueryIdentifier { get }
}

public protocol HasChildren {
    var elements: [PageElement] { get }
}


public struct StaticText: PageElement {
    public let elementIdentifier: PageElementIdentifier

    let identifier: String?
    let text: String

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
}


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


public struct NavigationBar: PageElement, HasChildren {
    public let elementIdentifier: PageElementIdentifier

    let identifier: String?
    public let elements: [PageElement]

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .navigationBar,
            identifier: identifier,
            label: nil,
            value: nil,
            descendants: elements.map { $0.queryIdentifier }
        )
    }

    init(identifier: String, elements: [PageElement]) {
        self.elementIdentifier = .dynamic
        self.identifier = identifier
        self.elements = elements
    }

    public init(
        identifier: String? = nil,
        @PageBuilder pageDescription: () -> PageDescription,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.elements = pageDescription().elements
    }
}


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


public struct CollectionView: PageElement, HasChildren {
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
            elementType: .collectionView,
            identifier: nil,
            label: nil,
            value: nil,
            descendants: elements.map { $0.queryIdentifier }
        )
    }
}


public struct Cell: PageElement, HasChildren {
    public let elementIdentifier: PageElementIdentifier

    let identifier: String?

    public let elements: [PageElement]

    init(identifier: String?, elements: [PageElement]) {
        self.elementIdentifier = .dynamic
        self.identifier = identifier
        self.elements = elements
    }

    public init(
        identifier: String? = nil,
        @PageBuilder elements: () -> PageDescription,
        file: String = #file,
        line: UInt = #line,
        column: UInt = #column
    ) {
        self.elementIdentifier = .init(file: file, line: line, column: column)
        self.identifier = identifier
        self.elements = elements().elements
    }

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .cell,
            identifier: identifier,
            label: nil,
            value: nil,
            descendants: elements.map { $0.queryIdentifier }
        )
    }
}


public struct TextField: PageElement, TextInput {
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
            elementType: .textField,
            identifier: identifier,
            label: nil,
            value: value,
            descendants: []
        )
    }
}


public struct SecureTextField: PageElement, TextInput {
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


public protocol TextInput: PageElement {}

extension TextInput {
    public func type(text: String) {
        // TODO: better activity description
        XCTContext.runActivity(named: "Typing text \(text.debugDescription)") { activity in
            guard let element = getXCUIElementQuery(forAction: "type(text: \(text.debugDescription)")?.element else { return }
            element.tap()
            element.typeText(text)
        }
    }
}


extension PageElement {

    func getXCUIElementQuery(forAction action: String) -> XCUIElementQuery? {
        guard let cacheEntry = elementCache[elementIdentifier] else {
            assertionFailure("\(action) called before page.exists()!")
            return nil
        }

        let application: XCUIApplication
        if let bundleIdentifier = cacheEntry.application {
            application = XCUIApplication(bundleIdentifier: bundleIdentifier)
        } else {
            application = XCUIApplication()
        }

        guard let firstPathComponent = cacheEntry.path.first else { return nil }
        var query: XCUIElementQuery = application.query(queryIdentifier: firstPathComponent)
        for nextPathComponent in cacheEntry.path[1...] {
            query = query.query(queryIdentifier: nextPathComponent)
        }

        return query
    }

    public func tap() {
        guard let element = getXCUIElementQuery(forAction: "tap()")?.element else { return }
        element.tap()
    }

    public func tapAny() {
        guard let element = getXCUIElementQuery(forAction: "tap()")?.firstMatch else { return }
        element.tap()
    }
}


extension XCUIElementTypeQueryProvider {
    func query(queryIdentifier: QueryIdentifier) -> XCUIElementQuery {
        let usedQuery: XCUIElementQuery
        switch queryIdentifier.elementType {
        case .button:
            usedQuery = buttons
        case .staticText:
            usedQuery = staticTexts
        case .collectionView:
            usedQuery = collectionViews
        case .cell:
            usedQuery = cells
        case .tabBar:
            usedQuery = tabBars
        case .textField:
            usedQuery = textFields
        case .navigationBar:
            usedQuery = navigationBars
        case .secureTextField:
            usedQuery = secureTextFields
        default:
            fatalError()
        }
        return usedQuery.matching(NSPredicate(block: { object, _ in
            // Apple's documentation says that the passed object is `XCUIElementAttributes`, but the object is a
            // `XCUIElementSnapshot` (which implements `XCUIElementAttributes`, so we can use this hack.
            guard let snapshot = object as? XCUIElementSnapshot else {
                assertionFailure()
                return false
            }
            guard snapshot.elementType == queryIdentifier.elementType else { return false }
            if let identifier = queryIdentifier.identifier {
                guard snapshot.identifier == identifier else { return false }
            }
            if let label = queryIdentifier.label {
                guard snapshot.matches(searchedLabel: label) else { return false }
            }
            if let searchedValue = queryIdentifier.value, let value = snapshot.value {
                guard value as? String == searchedValue else { return false }
            }
            for descendant in queryIdentifier.descendants {
                guard !snapshot.find(queryIdentifier: descendant).isEmpty else { return false}
            }
            return true
        }))
    }
}


extension PageElement {
    func exists(in snapshot: XCUIElementSnapshot) -> Bool {
        snapshot.find(queryIdentifier: queryIdentifier).isEmpty == false
    }
}


private extension XCUIElementSnapshot {

    func matches(searchedLabel: String) -> Bool {
        let variableMatches = TestData.regex.matches(
            in: searchedLabel,
            range: NSRange(location: 0, length: searchedLabel.utf16.count)
        )
        guard !variableMatches.isEmpty else {
            return searchedLabel == label
        }

        let variables: [UUID] = variableMatches.compactMap { match -> UUID? in
            guard let range = Range(NSRange(location: match.range.location + 1, length: match.range.length - 2), in: searchedLabel) else { return nil }
            return UUID(uuidString: String(searchedLabel[range]))
        }

        var text = searchedLabel
        for variable in variables {
            text = text.replacingOccurrences(of: "{\(variable.uuidString)}", with: "(.*)")
        }
        guard let regex = try? NSRegularExpression(pattern: "^\(text)$") else {
            assertionFailure()
            return false
        }
        let valueMatches = regex.matches(in: label, range: NSRange(location: 0, length: label.utf16.count))
        for (index, match) in valueMatches.enumerated() {
            guard let range = Range(match.range(at: 1), in: label) else { continue }
            let value = label[range]
            TestData[variables[index]] = String(value)
        }

        return true
    }

    func find(queryIdentifier: QueryIdentifier) -> [XCUIElementSnapshot] {
        // TODO: We flatten the entire tree which is not very efficient. We could cancel when we find the element and
        //   don't need to walk the rest of the tree.
        flatten(element: self).filter { element in
            guard element.elementType == queryIdentifier.elementType else { return false }
            if let identifier = queryIdentifier.identifier {
                guard element.identifier == identifier else { return false }
            }
            if let label = queryIdentifier.label {
                guard element.matches(searchedLabel: label) else { return false }
            }
            if let searchedValue = queryIdentifier.value, let value {
                guard value as? String == searchedValue else { return false }
            }
            for descendant in queryIdentifier.descendants {
                guard find(queryIdentifier: descendant).isEmpty == false else { return false }
            }
            return true
        }
    }
}


extension PageElement {
    var declaration: String {
        "\(elementIdentifier.file) line \(elementIdentifier.line), column \(elementIdentifier.column)"
    }
}


private func flatten(element: XCUIElementSnapshot) -> [XCUIElementSnapshot] {
    return [element] + element.children.flatMap(flatten(element:))
}
