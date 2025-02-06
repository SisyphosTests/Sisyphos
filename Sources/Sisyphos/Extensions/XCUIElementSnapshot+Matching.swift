import XCTest


extension XCUIElementSnapshot {

    /// Checks if the given element matches this element snapshot, so the element is actually the element from which
    /// this snapshot was created.
    func matches(element: XCUIElement) -> Bool {
        // The private Apple API crashes if elements have different types. That's why we check upfront.
        guard element.elementType == self.elementType else { return false }
        // It's not expressed in the type system, but all of Apple's implementations of `XCUIElementSnapshot` are
        // actually NSObjects.
        guard
            let selfObject = self as? NSObject,
            let elementObject = element as? NSObject
        else {
            return false
        }

        return selfObject.matches(element: elementObject)
    }

    /// Checks if the given snapshot matches this element snapshot, so both snapshots are snapshots of the same element.
    func matches(snapshot: XCUIElementSnapshot) -> Bool {
        // The private Apple API crashes if elements have different types. That's why we check upfront.
        guard snapshot.elementType == self.elementType else { return false }
        // It's not expressed in the type system, but all of Apple's implementations of `XCUIElementSnapshot` are
        // actually NSObjects.
        guard
            let selfObject = self as? NSObject,
            let elementObject = snapshot as? NSObject
        else {
            return false
        }

        return selfObject.matches(element: elementObject)
    }
}


private extension NSObject {
    func matches(element: NSObject) -> Bool {
        typealias MethodType = @convention(c) (NSObject, Selector, NSObject) -> Bool
        let selector = Selector("_matchesElement:")
        let methodImplementation = unsafeBitCast(method(for: selector), to: MethodType.self)
        return methodImplementation(self, selector, element)
    }
}
