@propertyWrapper public struct Shared<Value> {
    private final class Storage {
        var value: Value
        init(_ value: Value) { self.value = value }
    }

    private let storage: Storage

    public var wrappedValue: Value {
        get { storage.value }
        nonmutating set { storage.value = newValue }
    }

    public init(wrappedValue: Value) {
        self.storage = Storage(wrappedValue)
    }
}

extension Shared: CustomReflectable {
    public var customMirror: Mirror {
        Mirror(self, children: ["wrappedValue": wrappedValue as Any])
    }
}
