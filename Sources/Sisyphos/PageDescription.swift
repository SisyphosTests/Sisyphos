

public struct PageDescription {
    public let elements: [PageElement]
}

extension PageDescription {
    public func generatePageSource(pageName: String = "DebugPage") -> String {
        var output = "struct \(pageName): Page {\n  var body: PageDescription {\n"
        for element in elements {
            output += element.prettyPrint(indentation: 2) + "\n"
        }
        output += "  }\n}"

        return output
    }
}


private extension PageElement {
    func prettyPrint(indentation: Int) -> String {
        let indentationString = String(repeating: "  ", count: indentation)
        var output = "\(indentationString)\(String(describing: Swift.type(of: self)))"
        var properties: [(propertyName: String, value: String)] = Mirror(reflecting: self).children.compactMap { (property, value) in
            guard let property else { return nil }
            guard !["elementIdentifier", "elements"].contains(property) else { return nil }
            guard let stringValue = value as? String, !stringValue.isEmpty else { return nil }

            return (
                propertyName: property,
                value: stringValue.debugDescription
            )
        }
        if !properties.isEmpty || !(self is HasChildren) {
            output += "("
        }
        properties.sort { left, right in
            switch left.propertyName {
            case "value":
                return false
            case "label":
                return right.propertyName != "identifier"
            case "text":
                return false
            default:
                return true
            }
        }
        for (index, (propertyName, value)) in properties.enumerated() {
            if index != 0 {
                output += ", "
            }
            // special treatment for text, which only exists on StaticText
            if propertyName == "text" {
                output += value
            } else {
                output += "\(propertyName): \(value)"
            }
        }
        if !properties.isEmpty || !(self is HasChildren) {
            output += ")"
        }
        if let hasChildren = self as? HasChildren {
            output += " {\n"
            for child in hasChildren.elements {
                output += child.prettyPrint(indentation: indentation + 1) + "\n"
            }
            output += "\(indentationString)}"
        }
        return output
    }
}
