import XCTest


struct Snapshot {
    let index: UInt
    let path: [PathStep]
    let snapshotIdentifier = UUID()
    let elementType: XCUIElement.ElementType
    let identifier: String
    let label: String
    let value: String?

    let children: [Snapshot]

    private init(xcuisnapshot: XCUIElementSnapshot, counter: Counter, pathSoFar: [PathStep]) {
        let pathToElement = pathSoFar + [
            PathStep(
                elementType: xcuisnapshot.elementType,
                identifier: xcuisnapshot.identifier,
                label: xcuisnapshot.label,
                value: xcuisnapshot.value as? String
            )
        ]
        index = counter.next()
        path = pathToElement
        elementType = xcuisnapshot.elementType
        identifier = xcuisnapshot.identifier
        label = xcuisnapshot.label
        value = xcuisnapshot.value as? String
        children = xcuisnapshot.children.map { child in
            Snapshot(
                xcuisnapshot: child,
                counter: counter,
                pathSoFar: pathToElement
            )
        }
    }

    init(xcuisnapshot: XCUIElementSnapshot) {
        self.init(xcuisnapshot: xcuisnapshot, counter: Counter(), pathSoFar: [])
    }

    /// IMPORTANT: Doesn't check the children. Only checks the attributes on the element itself.
    func matchesQueryAttributes(queryIdentifier: QueryIdentifier) -> Bool {
        guard queryIdentifier.elementType == elementType else { return false }
        if let neededIdentifier = queryIdentifier.identifier {
            guard identifier == neededIdentifier else { return false }
        }
        if let neededLabel = queryIdentifier.label {
            guard label.matches(searchedLabel: neededLabel) else { return false }
        }
        if let neededValue = queryIdentifier.value {
            guard value == neededValue else { return false }
        }

        return true
    }

    public struct PathStep: Equatable {
        let elementType: XCUIElement.ElementType
        let identifier: String
        let label: String
        let value: String?
    }
}


private class Counter {
    private var count: UInt = 0

    func next() -> UInt {
        count += 1
        return count
    }
}


class ElementFinder {
    let snapshot: Snapshot
    let page: Page

    var paths: [[Snapshot.PathStep]] = []

    init(page: Page, snapshot: XCUIElementSnapshot) {
        self.page = page
        self.snapshot = Snapshot(xcuisnapshot: snapshot)
    }

    func check() -> [PageElement] {
        var missingElements: [PageElement] = []
        var indexOfPreviousElement: UInt = 0
        for element in page.body.elements {
            registerElement(element: element)
            guard let result = find(element: element, after: indexOfPreviousElement, in: snapshot) else {
                missingElements.append(element)
                continue
            }
            indexOfPreviousElement = result.index
        }

        return missingElements
    }

    private func registerElement(element: PageElement) {
        elementPathCache[element.elementIdentifier] = CacheEntry(page: page, location: nil)
        if let hasChildren = element as? HasChildren {
            for child in hasChildren.elements {
                registerElement(element: child)
            }
        }
    }

    private func find(element: PageElement, after elementIndex: UInt, in snapshot: Snapshot) -> Snapshot? {
        elementItSelf:
        if snapshot.index > elementIndex && snapshot.matchesQueryAttributes(queryIdentifier: element.queryIdentifier) {
            if let hasChildren = element as? HasChildren {
                var previousIndex = snapshot.index
                for descendant in hasChildren.elements {
                    guard let descendantElement = find(element: descendant, after: previousIndex, in: snapshot) else {
                        break elementItSelf
                    }
                    previousIndex = descendantElement.index
                }
            }

            if paths.contains(snapshot.path) {
                let index = paths.filter { $0 == snapshot.path }.count
                elementPathCache[element.elementIdentifier] = .init(
                    page: page,
                    location: .init(path: snapshot.path, index: index)
                )
            } else {
                elementPathCache[element.elementIdentifier] = .init(
                    page: page,
                    location: .init(path: snapshot.path, index: 0)
                )
            }
            paths.append(snapshot.path)

            return snapshot
        }

        for child in snapshot.children {
            if let result = find(element: element, after: elementIndex, in: child) {
                return result
            }
        }

        return nil
    }
}

