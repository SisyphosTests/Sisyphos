import Foundation



@propertyWrapper public struct TestData {

    private static var valueStore: [UUID: String] = [:]

    static var isEvaluatingBody = false

    static let regex = try! NSRegularExpression(
        pattern: "\\{([A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12})\\}",
        options: []
    )

    let variableIdentifier = UUID()

    public var wrappedValue: String {
        get {
            if Self.isEvaluatingBody {
                return "{\(variableIdentifier.uuidString)}"
            }
            return Self.valueStore[variableIdentifier] ?? "<NO VALUE>"
        }
    }

    public init() {

    }

    static subscript(_ identifier: UUID) -> String? {
        set {
            valueStore[identifier] = newValue
        }
        get {
            valueStore[identifier]
        }
    }
}
