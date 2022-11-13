
@resultBuilder public struct PageBuilder {
    public static func buildBlock(_ components: PageDescriptionBlock...) -> PageDescription {
        PageDescription(elements: components.flatMap { $0.buildingBlocks })
    }

    // MARK: - Conditions

    public static func buildIf(_ value: PageDescription?) -> PageDescription {
        guard let value else { return PageDescription(elements: []) }

        return value
    }

    public static func buildEither(first component: PageDescription) -> PageDescription {
        component
    }

    public static func buildEither(second component: PageDescription) -> PageDescription {
        component
    }
}


public protocol PageDescriptionBlock {
    var buildingBlocks: [PageElement] { get }
}


public extension PageElement {
    var buildingBlocks: [PageElement] { [self] }
}


extension PageDescription: PageDescriptionBlock {
    public var buildingBlocks: [PageElement] { elements }
}
