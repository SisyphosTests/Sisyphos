

public struct PageElementIdentifier: Hashable {
    let file: String
    let line: UInt
    let column: UInt

    /// A special identifier which is used when page elements are created dynamically, e.g. in a automatically created
    /// page description of a running app.
    static let dynamic: Self = .init(file: "", line: 0, column: 0)
}
