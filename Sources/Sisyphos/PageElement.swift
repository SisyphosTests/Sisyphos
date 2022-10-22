import XCTest


public protocol PageElement {
    var elementIdentifier: UUID { get }

    var queryIdentifier: QueryIdentifier { get }
}

public protocol HasChildren {
    var elements: [PageElement] { get }
}


public struct StaticText: PageElement {
    public let elementIdentifier = UUID()

    let text: String

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .staticText,
            identifier: nil,
            label: text,
            descendants: []
        )
    }

    public init(_ text: String) {
        self.text = text
    }
}


public struct Button: PageElement {
    public let elementIdentifier = UUID()

    let label: String?
    let identifier: String?

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .button,
            identifier: identifier,
            label: label,
            descendants: []
        )
    }

    public init(label: String? = nil, identifier: String? = nil) {
        self.label = label
        self.identifier = identifier
    }
}


public struct NavigationBar: PageElement, HasChildren {
    public let elementIdentifier = UUID()

    let identifier: String
    public let elements: [PageElement]

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .navigationBar,
            identifier: identifier,
            label: nil,
            descendants: elements.map { $0.queryIdentifier }
        )
    }

    init(identifier: String, elements: [PageElement]) {
        self.identifier = identifier
        self.elements = elements
    }

    public init(identifier: String, @PageBuilder pageDescription: () -> PageDescription) {
        self.identifier = identifier
        self.elements = pageDescription().elements
    }
}


public struct TabBar: PageElement, HasChildren {
    public let elementIdentifier = UUID()

    public let elements: [PageElement]

    init(elements: [PageElement]) {
        self.elements = elements
    }

    public init(@PageBuilder elements: () -> PageDescription) {
        self.elements = elements().elements
    }

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .tabBar,
            identifier: nil,
            label: nil,
            descendants: elements.map { $0.queryIdentifier }
        )
    }
}


public struct CollectionView: PageElement, HasChildren {
    public let elementIdentifier = UUID()

    public let elements: [PageElement]

    init(elements: [PageElement]) {
        self.elements = elements
    }

    public init(@PageBuilder elements: () -> PageDescription) {
        self.elements = elements().elements
    }

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .collectionView,
            identifier: nil,
            label: nil,
            descendants: elements.map { $0.queryIdentifier }
        )
    }
}


public struct Cell: PageElement, HasChildren {
    public let elementIdentifier = UUID()

    public let elements: [PageElement]

    init(elements: [PageElement]) {
        self.elements = elements
    }

    public init(@PageBuilder elements: () -> PageDescription) {
        self.elements = elements().elements
    }

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .cell,
            identifier: nil,
            label: nil,
            descendants: elements.map { $0.queryIdentifier }
        )
    }
}


public struct TextField: PageElement {
    public let elementIdentifier = UUID()

    public let identifier: String?

    public init(identifier: String? = nil) {
        self.identifier = identifier
    }

    public var queryIdentifier: QueryIdentifier {
        .init(
            elementType: .textField,
            identifier: identifier,
            label: nil,
            descendants: []
        )
    }
}


extension TextField {
    public func type(text: String) {
        // TODO: better activity description
        XCTContext.runActivity(named: "Typing text \(text.debugDescription)") { activity in
            guard let app = getApp(forAction: "type(text: \(text.debugDescription)") else { return }
            let element = query(appending: app.windows).element
            if !element.hasFocus {
                element.tap()
            }
            element.typeText(text)
        }
    }
}

extension PageElement {

    func getApp(forAction action: String) -> XCUIApplication? {
        guard let applicationIdentifier = stableElementsStore[elementIdentifier] else {
            assertionFailure("\(action) called before page.exists()!")
            return nil
        }
        if let applicationIdentifier {
            return XCUIApplication(bundleIdentifier: applicationIdentifier)
        }
        return XCUIApplication()
    }

    public func tap() {
        guard let app = getApp(forAction: "tap()") else { return }
        query(appending: app.windows).element.tap()
    }
}


extension PageElement {
    func query(appending query: XCUIElementQuery) -> XCUIElementQuery {
        let usedQuery: XCUIElementQuery
        switch queryIdentifier.elementType {
        case .button:
            usedQuery = query.buttons
        case .staticText:
            usedQuery = query.buttons
        case .collectionView:
            usedQuery = query.collectionViews
        case .cell:
            usedQuery = query.cells
        case .tabBar:
            usedQuery = query.tabBars
        case .textField:
            usedQuery = query.textFields
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
            for descendant in queryIdentifier.descendants {
                guard !snapshot.find(queryIdentifier: descendant).isEmpty else { return false}
            }
            return true
        }))
    }

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
            for descendant in queryIdentifier.descendants {
                guard find(queryIdentifier: descendant).isEmpty == false else { return false }
            }
            return true
        }
    }
}


private func flatten(element: XCUIElementSnapshot) -> [XCUIElementSnapshot] {
    return [element] + element.children.flatMap(flatten(element:))
}
