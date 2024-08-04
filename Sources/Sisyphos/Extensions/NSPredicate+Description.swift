import XCTest


extension NSPredicate {
    convenience init(step: Snapshot.PathStep) {
        assert(Thread.isMainThread)

        self.init(block: { object, _ in
            guard let snapshot = object as? XCUIElementAttributes else {
                assertionFailure()
                return false
            }
            return snapshot.elementType == step.elementType
              && snapshot.identifier == step.identifier
              && snapshot.label.matches(searchedLabel: step.label)
              && snapshot.value as? String == step.value
        })

        stepByPredicate.setObject(Box(value: step), forKey: self)
    }
}

/// A mapping where the key is a predicate that was created by Sisyphos and the value is the corresponding step in a
/// snapshot path. This is needed so we can provide useful output in the test reports.
private var stepByPredicate: NSMapTable<NSPredicate, Box<Snapshot.PathStep>> = NSMapTable.weakToStrongObjects()

private final class Box<Value> {
    let value: Value

    init(value: Value) {
        self.value = value
    }
}


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
        guard let step = stepByPredicate.object(forKey: self)?.value else { return super.description }
        var attributes: [String] = [
            "element=\(step.elementType)",
        ]
        if !step.identifier.isEmpty {
            attributes.append("identifier=\(step.identifier.debugDescription)")
        }
        if !step.label.isEmpty {
            attributes.append("label=\(step.label.debugDescription)")
        }
        if let value = step.value {
            attributes.append("value=\(value.debugDescription)")
        }

        return "{\(attributes.joined(separator: ", "))}"
    }
}
