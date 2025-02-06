import XCTest


extension NSPredicate {
    convenience init(snapshot: XCUIElementSnapshot) {
        assert(Thread.isMainThread)

        self.init(block: { element, _ in
            guard let elementSnapshot = element as? XCUIElementSnapshot else { return false }
            return snapshot.matches(snapshot: elementSnapshot)
        })

        snapshotByPredicate.setObject(snapshot, forKey: self)
    }
}

/// A mapping where the key is a predicate that was created by Sisyphos and the value is the corresponding element
/// snapshot that is used for matching in the predicate. This is needed so we can provide useful output in the test
/// reports.
private var snapshotByPredicate: NSMapTable<NSPredicate, XCUIElementSnapshot> = NSMapTable.weakToStrongObjects()


extension NSPredicate {
    /// When we use a predicate in an element query to match elements, the `description` of the predicate is used in the
    /// test reports. Unfortunately, the description isn't really helpful and the test report looks like
    /// `Find: Elements matching predicate 'BLOCKPREDICATE(0x600000ceb750)'`. That's why we implement our own
    /// description that gives important information.
    ///
    /// The default way to implement our own helpful description would be to create a subclass of NSPredicate that
    /// overrides the description. While in theory it's possible to create subclasses of NSPredicate, in practice it's
    /// not really possible. NSPredicate is a class cluster and XCTest uses Apple's knowledge of implementation details
    /// to differentiate between the different predicate types in element queries. So if you pass your own NSPredicate
    /// subclass in an element query, then XCTest will throw an assertion.
    ///
    /// Because of that, we use Swift's dynamic method replacement to replace the description of NSPredicate. If the
    /// predicate is created by Sisyphos, then we provide helpful output in the test reports that look like
    /// `Find: Elements matching predicate '{element=textField, identifier="some identifier"}'`. If the predicate is
    /// not created by Sisyphos, then it falls back to the default description of NSPredicate.
    @_dynamicReplacement(for: description)
    var sisyphosDescription: String {
        guard let snapshot = snapshotByPredicate.object(forKey: self) else { return super.description }
        var attributes: [String] = [
            "element=\(snapshot.elementType)",
        ]
        if !snapshot.identifier.isEmpty {
            attributes.append("identifier=\(snapshot.identifier.debugDescription)")
        }
        if !snapshot.label.isEmpty {
            attributes.append("label=\(snapshot.label.debugDescription)")
        }
        if let value = snapshot.value as? String {
            attributes.append("value=\(value.debugDescription)")
        }

        return "{\(attributes.joined(separator: ", "))}"
    }
}
