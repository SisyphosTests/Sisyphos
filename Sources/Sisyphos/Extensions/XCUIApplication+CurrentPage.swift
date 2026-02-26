import XCTest


public extension XCUIApplication {
    var currentPage: PageDescription? {
        guard let snapshot = try? snapshot() else { return nil }
        return snapshot.toPage()
    }
}


extension XCUIElementSnapshot {
    func toPage() -> PageDescription {
        PageDescription(elements: flatten(element: self))
    }
}


private func extract(element: XCUIElementSnapshot) -> PageElement? {
    switch element.elementType {
    case .alert:
        return Alert(
            identifier: element.identifier,
            elements: element.children.flatMap(flatten(element:))
        )
    case .button:
        return Button(
            identifier: element.identifier,
            label: element.label
        )
    case .cell:
        return Cell(
            identifier: element.identifier,
            elements: element.children.flatMap(flatten(element:))
        )
    case .collectionView:
        return CollectionView(
            elements: element.children.flatMap(flatten(element:))
        )
    case .navigationBar:
        return NavigationBar(
            identifier: element.identifier,
            elements: element.children.flatMap(flatten(element:))
        )
    // Usually, there are a lot of `Other` elements which produce a lot of visual noise.
    // Because of that, we only include them if they have either a label or an identifier.
    case .other where !element.label.isEmpty || !element.identifier.isEmpty:
        return Other(
            identifier: element.identifier,
            label: element.label,
            elements: element.children.flatMap(flatten(element:))
        )
    case .secureTextField:
        return SecureTextField(
            identifier: element.identifier,
            value: element.value as? String
        )
    case .staticText:
        return StaticText(
            identifier: element.identifier,
            element.label
        )
    case .switch:
        return Switch(
            identifier: element.identifier,
            label: element.label
        )
    case .tabBar:
        return TabBar(
            elements: element.children.flatMap(flatten(element:))
        )
    case .textField:
        return TextField(
            identifier: element.identifier,
            value: element.value as? String
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
