/// An identifier to uniquely identify elements.
///
/// Elements are identified by their position in the source code. This has the additional benefit that the identifer
/// can be used for helpful debug information.
public struct PageElementIdentifier: Hashable {
    /// The source file in which the element is defined.
    let file: String
    /// The line in the source code where the element is defined.
    let line: UInt
    /// The column in the source code where the element is defined.
    let column: UInt

    /// A special identifier which is used when page elements are created dynamically, e.g. in a automatically created
    /// page description of a running app.
    static let dynamic: Self = .init(file: "", line: 0, column: 0)
}
