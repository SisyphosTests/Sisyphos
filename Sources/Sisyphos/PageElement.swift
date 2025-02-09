import XCTest


public protocol PageElement: PageDescriptionBlock {
    var elementIdentifier: PageElementIdentifier { get }

    var queryIdentifier: QueryIdentifier { get }
}

protocol HasChildren {
    var elements: [PageElement] { get }
}


extension PageElement {

    func getXCUIElement(forAction action: String) -> XCUIElement? {
        handleInterruptions()

        getPage()?.refreshElementCache()
        guard let cacheEntry = elementPathCache[elementIdentifier] else {
            assertionFailure("\(action) called before page.exists()!")
            return nil
        }
        guard let snapshot = cacheEntry.snapshot else {
            assertionFailure("Try to run \(action) on an element of a non-existing page")
            return nil
        }

        let application = cacheEntry.page.xcuiapplication
        let query = application.descendants(matching: snapshot.elementType).matching(NSPredicate(snapshot: snapshot))

        return query.firstMatch
    }

    /// It is used for getting the window that contains the element
    /// - Returns: Corresponding window
    func getXCUIWindow(forAction action: String) -> XCUIElement? {
        handleInterruptions()

        getPage()?.refreshElementCache()
        guard let cacheEntry = elementPathCache[elementIdentifier] else {
            assertionFailure("\(action) called before page.exists()!")
            return nil
        }
        guard let snapshot = cacheEntry.snapshot else {
            assertionFailure("Try to run \(action) on an element of a non-existing page")
            return nil
        }
        let application = cacheEntry.page.xcuiapplication
        let query = application.windows.containing(NSPredicate(snapshot: snapshot))

        return query.firstMatch
    }

    private func getPage() -> Page? {
        guard let cacheEntry = elementPathCache[elementIdentifier] else {
            return nil
        }

        return cacheEntry.page
    }

    /// Sends a tap event to a hittable point the system computes for the element.
    public func tap() {
        guard let element = getXCUIElement(forAction: "tap()") else { return }
        element.waitUntilStablePosition()
        element.tap()
    }

    /// Sends a tap event to the hittable point that is described by the given normalized coordinate.
    ///
    /// In the current scenarios, we observed that the static text element on the WebView is not hittable when the
    /// regular `tap()` function has been used. The reason is that XCUIElement recognizes the object as not accessible,
    /// but it's not true. To avoid non-accessible situations, we need to tap on the component by using offset
    /// coordinates.
    /// - Parameter coordinates: Normalized offset coordinates to specify tap position.
    public func tap(usingCoordinates coordinates: CGVector) {
        guard let element = getXCUIElement(forAction: "tap()") else { return }
        element.waitUntilStablePosition()
        element.coordinate(withNormalizedOffset: coordinates).tap()
    }

    /// Types a string into the element.
    ///
    /// The element doesn't need to have keyboard focus prior to typing. To make sure that the element has keyboard
    /// focus, a tap event is sent to the element before typing.
    ///
    /// - Parameters:
    ///   - text:
    ///       The string which should be typed into the element.
    ///   - dismissKeyboard:
    ///       Whether or not the keyboard should be dismissed after typing the text has finished. If the keyboard should
    ///       be dismissed, it's dismissed by tapping the `Done` button on the keyboard.
    public func type(text: String, dismissKeyboard: Bool = true) {
        // TODO: better activity description
        XCTContext.runActivity(named: "Typing text \(text.debugDescription)") { activity in
            guard let element = getXCUIElement(forAction: "type(text: \(text.debugDescription)") else { return }
            element.waitUntilStablePosition()
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            element.typeText(text)

            guard dismissKeyboard else { return }

            guard let dismissButton = getPage()?.xcuiapplication.keyboards.buttons["Done".localizedForSimulator] else {
                return
            }
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
            if dismissButton.isHittable {
                dismissButton.tap()
            }
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

    /// Scrolls on the screen until the element is in the visible area.
    /// - Parameters:
    ///   - direction: Indicates the direction of the scroll.
    ///   - maxTryCount: Specifies how many attempts should it apply.
    ///   - file: Name of the file that will be displayed if it fails.
    ///   - line: Line number that will be displayed if it fails.
    // TODO: Add PageBuilder argument to make the function more generic
    public func scrollUntilVisibleOnScreen(
        direction: ScrollDirection,
        maxTryCount: Int = 5,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        guard let element = getXCUIElement(forAction: "scroll until visible") else { return }
        guard let app = getPage()?.xcuiapplication else { return }
        guard let window = getXCUIWindow(forAction: "scroll until visible") else { return }
        guard !CGRectContainsRect(window.frame, element.frame) else { return }
        var tryCounter = maxTryCount
        var startCoordinate = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        repeat {
            var endCoordinate = startCoordinate
            switch direction {
            case .down:
                endCoordinate = startCoordinate.withOffset(CGVector(dx: 0, dy: -window.frame.height/3))
                startCoordinate.press(forDuration: 0.05, thenDragTo: endCoordinate)
            case .up:
                endCoordinate = startCoordinate.withOffset(CGVector(dx: 0, dy: window.frame.height/3))
                startCoordinate.press(forDuration: 0.05, thenDragTo: endCoordinate)
            case .left:
                endCoordinate = startCoordinate.withOffset(CGVector(dx: window.frame.width/3, dy: 0))
                startCoordinate.press(forDuration: 0.05, thenDragTo: endCoordinate)
            case .right:
                endCoordinate = startCoordinate.withOffset(CGVector(dx: -window.frame.width/3, dy: 0))
                startCoordinate.press(forDuration: 0.05, thenDragTo: endCoordinate)
            }
            element.waitUntilStablePosition()
            tryCounter -= 1
            startCoordinate = endCoordinate
            guard !CGRectContainsRect(window.frame, element.frame) else { return }
        } while tryCounter > 0

        XCTFail(
            "Did not exist after attempting \(maxTryCount) times scrolling",
            file: file,
            line: line
        )
    }

    /// For debugging only. Please don't use this for writing tests.
    public var element: XCUIElement {
        getXCUIElement(forAction: "debugging the element")!
    }
}


public enum ScrollDirection {
    case down
    case up
    case left
    case right
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

/// Automatically handles system alerts like push notification permissions as well as user defined UI interruptions.
private func handleInterruptions() {
    UIInterruptionsObserver.shared.checkForInterruptions()
}
