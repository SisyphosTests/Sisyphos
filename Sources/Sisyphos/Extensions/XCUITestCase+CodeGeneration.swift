import XCTest


extension XCTestCase {
    public func startCodeGeneration(
        application: String? = nil,
        file: String = #file,
        line: UInt = #line
    ) {
        if let application {
            _startCodeGeneration(apps: [(XCUIApplication(bundleIdentifier: application), application)], file: file, line: line)
        } else {
            _startCodeGeneration(apps: [(XCUIApplication(), nil)], file: file, line: line)
        }
    }

    public func startCodeGeneration(
        applications: [String],
        file: String = #file,
        line: UInt = #line
    ) {
        guard !applications.isEmpty else {
            XCTFail("startCodeGeneration(applications:) requires at least one bundle identifier.")
            return
        }
        let apps = applications.map { (XCUIApplication(bundleIdentifier: $0), $0) }
        _startCodeGeneration(apps: apps, file: file, line: line)
    }

    private func _startCodeGeneration(
        apps: [(app: XCUIApplication, applicationName: String?)],
        file: String,
        line: UInt
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

        var lastSources = [Int: String]()

        while true {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
            for (index, (app, applicationName)) in apps.enumerated() {
                guard
                    let snapshot = try? app.snapshot(),
                    let page = app.currentPage
                else { continue }

                let identifier = snapshot.findFirstIdentifier() ?? "GeneratedPage"
                let sourceForComparison = page.generatePageSource(pageName: identifier, applicationName: applicationName)
                guard lastSources[index] != sourceForComparison else { continue }
                lastSources[index] = sourceForComparison
                let pageName = identifier.generatePageName()
                let source = page.generatePageSource(pageName: pageName, applicationName: applicationName)
                appendToSourceFile(addedContents: source + "\n\n")
            }
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
