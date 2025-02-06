import XCTest


final class ElementFinder {
    let snapshot: Snapshot
    let page: Page

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
        elementPathCache[element.elementIdentifier] = CacheEntry(page: page, snapshot: nil)
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

            elementPathCache[element.elementIdentifier] = .init(
                page: page,
                snapshot: snapshot.xcuisnapshot
            )

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

