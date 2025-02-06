import XCTest


struct Snapshot {
    let index: UInt
    let snapshotIdentifier = UUID()
    let xcuisnapshot: XCUIElementSnapshot

    var elementType: XCUIElement.ElementType {
        xcuisnapshot.elementType
    }
    var identifier: String {
        xcuisnapshot.identifier
    }
    var label: String {
        xcuisnapshot.label
    }
    var value: String? {
        xcuisnapshot.value as? String
    }

    let children: [Snapshot]

    private init(xcuisnapshot: XCUIElementSnapshot, counter: Counter) {
        index = counter.next()
        self.xcuisnapshot = xcuisnapshot
        children = xcuisnapshot.children.map { child in
            Snapshot(
                xcuisnapshot: child,
                counter: counter
            )
        }
    }

    init(xcuisnapshot: XCUIElementSnapshot) {
        self.init(xcuisnapshot: xcuisnapshot, counter: Counter())
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
}


private final class Counter {
    private var count: UInt = 0

    func next() -> UInt {
        count += 1
        return count
    }
}
