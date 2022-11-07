import XCTest


public protocol PageElement {
    var elementIdentifier: PageElementIdentifier { get }

    var queryIdentifier: QueryIdentifier { get }
}

protocol HasChildren {
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


public struct TextField: PageElement {
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


public struct SecureTextField: PageElement {
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


extension PageElement {

    func getXCUIElement(forAction action: String) -> XCUIElement? {
        guard let cacheEntry = elementCache[elementIdentifier] else {
            assertionFailure("\(action) called before page.exists()!")
            return nil
        }
        cacheEntry.page.refreshElementCache()
        guard let cacheEntry = elementCache[elementIdentifier] else {
            assertionFailure("\(action) called before page.exists()!")
            return nil
        }

        let application = cacheEntry.page.xcuiapplication
        let query = application.query(path: cacheEntry.path)

        return query.element(boundBy: cacheEntry.index)
    }

    private func getPage() -> Page? {
        guard let cacheEntry = elementCache[elementIdentifier] else {
            return nil
        }

        return cacheEntry.page
    }

    func getAllXCUIElements(forAction action: String) -> XCUIElementQuery? {
        guard let cacheEntry = elementCache[elementIdentifier] else {
            assertionFailure("\(action) called before page.exists()!")
            return nil
        }
        cacheEntry.page.refreshElementCache()
        guard let cacheEntry = elementCache[elementIdentifier] else {
            assertionFailure("\(action) called before page.exists()!")
            return nil
        }

        let application = cacheEntry.page.xcuiapplication

        return application.query(path: cacheEntry.path)
    }

    public func tap() {
        guard let element = getXCUIElement(forAction: "tap()") else { return }
        element.waitUntilStablePosition()
        element.tap()
    }

    public func tapAny() {
        guard let element = getAllXCUIElements(forAction: "tap()")?.firstMatch else { return }
        element.waitUntilStablePosition()
        element.tap()
    }

    public func type(text: String, dismissKeyboard: Bool = true) {
        // TODO: better activity description
        XCTContext.runActivity(named: "Typing text \(text.debugDescription)") { activity in
            guard let element = getXCUIElement(forAction: "type(text: \(text.debugDescription)") else { return }
            element.waitUntilStablePosition()
            element.tap()
            element.typeText(text)

            guard dismissKeyboard else { return }

            guard let toolbars = getPage()?.xcuiapplication.toolbars, toolbars.count > 0 else { return }
            let dismissButton = toolbars.firstMatch.buttons["Done".localizedForSimulator]
            guard dismissButton.exists else { return }
            // If this is a fresh simulator - which is very common on CI systems - then there's an overlay over the
            // keyboard which explains how to use the swipe keyboard. All of the buttons of the keyboard and its
            // toolbar are visible for the automation, but not tappable. We first need to dismiss the overlay.
            // Unfortunately this overlay is not part of the keyboard, so querying it via application.keyboards... will
            // not work. It doesn't have an accessibility identifier neither.
            if !dismissButton.isHittable {
                guard let app = getPage()?.xcuiapplication else { return }
                for button in app.buttons.matching(identifier: "Continue".localizedForSimulator).allElementsBoundByIndex {
                    guard button.isHittable else { continue }
                    button.tap()
                    break
                }
            }
            dismissButton.tap()
        }
    }

    public func waitUntilIsHittable(
        timeout: CFTimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let element = getXCUIElement(forAction: "wait until hittable") else { return }
        let deadline = Date(timeIntervalSinceNow: timeout)
        repeat {
            guard !element.isHittable else { return }
            _ = RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 1))
        } while Date() < deadline

        XCTFail(
            "Did not become hittable after \(timeout)s",
            file: file,
            line: line
        )
    }

    /// For debugging only. Please don't use this for writing tests.
    public var element: XCUIElement {
        getXCUIElement(forAction: "debugging the element")!
    }
}


// Needed hack because `XCUIApplication` doesn't conform to `XCUIElementQuery`.
protocol ChildrenQueryProvider {
    func descendants(matching: XCUIElement.ElementType) -> XCUIElementQuery
}

extension XCUIApplication: ChildrenQueryProvider {}
extension XCUIElementQuery: ChildrenQueryProvider {}


extension XCUIApplication {
    func query(path: [Snapshot.PathStep]) -> XCUIElementQuery {
        var usedQuery: ChildrenQueryProvider = self
        for step in path[1...] { // First step is always the application itself, so we skip it.
            guard step.elementType != .other else { continue }
            usedQuery = usedQuery.descendants(matching: step.elementType).matching(NSPredicate(block: { [step] object, _ in
                guard let snapshot = object as? XCUIElementAttributes else {
                    assertionFailure()
                    return false
                }
                return
                    snapshot.elementType == step.elementType
                    && snapshot.identifier == step.identifier
                    && snapshot.label.matches(searchedLabel: step.label)
                    && snapshot.value as? String == step.value
            }))
        }

        return usedQuery as! XCUIElementQuery
    }
}


extension String {

    func matches(searchedLabel: String) -> Bool {
        let variableMatches = TestData.regex.matches(
            in: searchedLabel,
            range: NSRange(location: 0, length: searchedLabel.utf16.count)
        )
        guard !variableMatches.isEmpty else {
            return searchedLabel == self
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
        let valueMatches = regex.matches(in: self, range: NSRange(location: 0, length: utf16.count))
        for (index, match) in valueMatches.enumerated() {
            guard let range = Range(match.range(at: 1), in: self) else { continue }
            let value = self[range]
            TestData[variables[index]] = String(value)
        }

        return true
    }
}
