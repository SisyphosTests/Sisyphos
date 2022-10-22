import XCTest


public extension XCUIApplication {
    var currentPage: PageDescription? {
        guard let snapshot = try? snapshot() else { return nil }
        let elements = flatten(element: snapshot)

        return PageDescription(elements: elements)
    }
}


private func extract(element: XCUIElementSnapshot) -> PageElement? {
    switch element.elementType {
    case .navigationBar:
        return NavigationBar(
            identifier: element.identifier,
            elements: element.children.flatMap(flatten(element:))
        )
    case .staticText:
        return StaticText(element.label)
    case .button:
        return Button(label: element.label)
    case .tabBar:
        return TabBar(
            elements: element.children.flatMap(flatten(element:))
        )
    case .collectionView:
        return CollectionView(
            elements: element.children.flatMap(flatten(element:))
        )
    case .cell:
        return Cell(
            elements: element.children.flatMap(flatten(element:))
        )
    case .textField:
        return TextField(
            identifier: element.identifier
        )
    default:
        return nil
    }
}

private func flatten(element: XCUIElementSnapshot) -> [PageElement] {
    if let extracted = extract(element: element) {
        return [extracted]
    }
    return element.children.flatMap(flatten(element:))
}
