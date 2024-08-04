import XCTest


extension XCTestCase {
    public func startCodeGeneration(
        application: String? = nil,
        file: String = #file,
        line: UInt = #line
    ) {

        #if !targetEnvironment(simulator)
        print("⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️")
        print("⚠️ You are running the code generation on a real device 📱")
        print("⚠️ The code generation will not automatically add the")
        print("⚠️ generated pages to the source file")
        print("⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️")
        #endif

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

        var lastSource = ""
        while true {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
            guard
                let snapshot = try? app.snapshot(),
                let page = app.currentPage
            else { continue }

            let identifier = snapshot.findFirstIdentifier() ?? "GeneratedPage"
            let sourceWithoutUniqueName = page.generatePageSource(pageName: identifier, applicationName: application)
            guard lastSource != sourceWithoutUniqueName else { continue }
            lastSource = sourceWithoutUniqueName
            appendToSourceFile(
                addedContents: sourceWithoutUniqueName + "\n\n"
            )
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

    /// Tries to find the first identifier in the element hierarchy that could be used as and identifier for the
    /// page that is currently displayed.
    func findFirstIdentifier() -> String? {
        if let identifier = find(elementType: .navigationBar)?.identifier, !identifier.isEmpty {
            return identifier
        }
        if let identifier = find(elementType: .other)?.identifier, !identifier.isEmpty {
            return identifier
        }

        return nil
    }
}
