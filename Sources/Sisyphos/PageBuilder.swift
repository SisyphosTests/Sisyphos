
@resultBuilder public struct PageBuilder {
    public static func buildBlock(_ components: PageDescriptionBlock...) -> PageDescription {
        PageDescription(elements: components.flatMap { $0.buildingBlocks })
    }

    // MARK: - Conditions

    public static func buildIf(_ value: PageDescription?) -> PageDescription {
        guard let value else { return .empty }

        return value
    }

    public static func buildEither(first component: PageDescription) -> PageDescription {
        component
    }

    public static func buildEither(second component: PageDescription) -> PageDescription {
        component
    }

    // MARK: - Optionals

    public static func buildOptional(_ component: PageDescription?) -> PageDescription {
        guard let component else { return .empty }

        return component
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


private extension PageDescription {
    static var empty: PageDescription { .init(elements: []) }
}


extension Optional: PageDescriptionBlock where Wrapped: PageElement {
    public var buildingBlocks: [PageElement] {
        switch self {
        case .none:
            return []
        case .some(let element):
            return [element]
        }
    }
}
