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

    struct PathStep: Equatable {
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
