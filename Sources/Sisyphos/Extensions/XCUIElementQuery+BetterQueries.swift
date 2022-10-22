import XCTest


public extension XCUIElementQuery {
    func matching<Value>(
        _ keyPath: KeyPath<XCUIElementAttributes, Value>,
        _ value: Value
    ) -> XCUIElementQuery where Value: Equatable
    {
        return matching(keyPath) { $0 == value }
    }

    /// TODO: The output of failed queries is not really helpful:
    ///   ```
    ///   Failed to Error Domain=com.apple.dt.xctest.ui-testing.error Code=10008
    ///   "No matches found for first query match sequence: `Descendants matching type TabBar` -> `Descendants matching
    ///   type Button` -> `Elements matching predicate 'BLOCKPREDICATE(0x6000033aab80)'`
    ///   ```
    ///   But we cannot create a subclass to make the output more helpful , because the created instance is actually a
    ///   `NSBlockPredicate` instance which is a hidden implementation. We could play around with swizzling methods on
    ///   this instance.
    func matching<Value>(
        _ keyPath: KeyPath<XCUIElementAttributes, Value>,
        evaluating check: @escaping (Value) -> Bool
    ) -> XCUIElementQuery
    {
        let predicate = NSPredicate(block: { object, _ in
            guard let element = object as? XCUIElementAttributes else { return false }
            let value = element[keyPath: keyPath]

            return check(value)
        })
        return matching(predicate)
    }
}
