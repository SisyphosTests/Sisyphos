import XCTest


extension XCTestCase {
    public func startCodeGeneration(
        application: String? = nil,
        file: String = #file,
        line: UInt = #line
    ) {
        func appendToSourceFile(addedContents: String) {
            // TODO: Give the user a hint if things go wrong.
            let fileUrl = URL(fileURLWithPath: file)
            guard let contents = try? String(contentsOf: fileUrl) else { return }
            try? (contents + addedContents).write(to: fileUrl, atomically: true, encoding: .utf8)
        }

        let app: XCUIApplication
        if let application {
            app = XCUIApplication(bundleIdentifier: application)
        } else {
            app = XCUIApplication()
        }

        var lastIdentifier: String = ""
        while true {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
            guard let snapshot = try? app.snapshot() else { continue }
            let identifier = snapshot.find(elementType: .navigationBar)?.identifier ?? ""
            guard identifier != lastIdentifier else { continue }

            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))

            guard let page = app.currentPage else { continue }
            appendToSourceFile(
                addedContents: page.generatePageSource(pageName: identifier.generatePageName()) + "\n\n"
            )
            lastIdentifier = identifier
        }
    }
}


private var usedPageNames: Set<String> = []

private extension String {
    func generatePageName() -> String {
        let generatedName = String(unicodeScalars.filter { CharacterSet.alphanumerics.contains($0)})
        var pageName = generatedName
        if usedPageNames.contains(pageName) {
            var iteration = 1
            repeat {
                iteration += 1
            } while usedPageNames.contains("\(pageName)\(iteration)")
            pageName = "\(pageName)\(iteration)"
        }

        usedPageNames.insert(pageName)
        return pageName
    }
}


private extension XCUIElementSnapshot {
    func find(elementType: XCUIElement.ElementType) -> XCUIElementSnapshot? {
        if self.elementType == elementType {
            return self
        }
        for child in children {
            if let element = child.find(elementType: elementType) {
                return element
            }
        }

        return nil
    }
}
