/// The results of a check whether a ``Page`` exists or not.
public struct PageExistsResults {

    /// The page's elements that were missing when the check was run. Empty if the page exists.
    public let missingElements: [PageElement]

    /// This will contain the full hierarchy of elements known to Sisyphos and doesn't try to only match the simplified
    /// requirements of the original page. Therefore it will contain more elements than the page in most situations as
    /// it also includes the elements in which the page is not interested.
    ///
    /// This property is nil if it was not possible to get a snapshot of the app, e.g. because the app wasn't running.
    public let actualPage: PageDescription?

    /// Whether or not a page exists, that means that it's currently visible on the screen according to its page
    /// description.
    public var isExisting: Bool {
        missingElements.isEmpty
    }
}
