import XCTest


final class ElementFinder {
    let snapshot: Snapshot
    let page: Page
    let additionalWebViewSnapshots: [Snapshot]

    init(page: Page, snapshot: XCUIElementSnapshot, additionalWebViews: [XCUIElementSnapshot] = []) {
        self.page = page
        self.snapshot = Snapshot(xcuisnapshot: snapshot)
        self.additionalWebViewSnapshots = additionalWebViews.map { Snapshot(xcuisnapshot: $0) }
    }

    // Note: The out-of-process web view fallback only applies to top-level WebView elements in
    // page.body.elements. A WebView nested inside another container (e.g. Cell { WebView { ... } })
    // won't trigger the fallback — the parent container's find() would fail before we get here.
    // This is a conceptual idea for a future improvement: the recursive find() could be extended to
    // attempt the out-of-process fallback when it encounters a .webView descendant that doesn't match
    // in the main snapshot.
    func check() -> [PageElement] {
        var missingElements: [PageElement] = []
        var indexOfPreviousElement: UInt = 0
        var usedAdditionalWebViewIDs = Set<UUID>()
        for element in page.body.elements {
            registerElement(element: element)
            if let result = find(element: element, after: indexOfPreviousElement, in: snapshot) {
                indexOfPreviousElement = result.index
            } else if element.queryIdentifier.elementType == .webView,
                      let match = findInAdditionalWebViews(element: element, excluding: usedAdditionalWebViewIDs) {
                // Found in out-of-process web views; don't update indexOfPreviousElement
                // since these aren't part of the main snapshot's index sequence
                usedAdditionalWebViewIDs.insert(match.snapshotIdentifier)
            } else {
                missingElements.append(element)
            }
        }

        return missingElements
    }

    private func findInAdditionalWebViews(element: PageElement, excluding usedIDs: Set<UUID>) -> Snapshot? {
        for webViewSnapshot in additionalWebViewSnapshots {
            guard !usedIDs.contains(webViewSnapshot.snapshotIdentifier) else { continue }
            if let result = find(element: element, after: 0, in: webViewSnapshot) {
                return result
            }
        }
        return nil
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

