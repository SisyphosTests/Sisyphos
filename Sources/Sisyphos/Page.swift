import XCTest


public protocol Page {
    var application: String? { get }

    @PageBuilder var body: PageDescription { get }
}

public extension Page {
    var application: String? { nil }
}


extension Page {
    var xcuiapplication: XCUIApplication {
        if let application {
            return XCUIApplication(bundleIdentifier: application)
        } else {
            return XCUIApplication()
        }
    }
}

public extension Page {
    func exists() -> Bool {
        buildPathCache()
        return XCTContext.runActivity(named: "Check if page \(String(describing: type(of: self))) exists") { activity in
            guard let snapshot = try? xcuiapplication.snapshot() else { return false }
            TestData.isEvaluatingBody = true
            for element in body.elements {
                guard element.exists(in: snapshot) else { return false }
            }
            TestData.isEvaluatingBody = false
            return true
        }
    }

    func waitForExistence(timeout: CFTimeInterval = 10) {
        let runLoop = RunLoop.current
        var iteration: CFTimeInterval = 0
        repeat {
            guard !exists() else { return }
            // TODO: checking the UI also took some time already, so this method actually waits longer than the timeout.
            //   Refactor to make it respect the timeout.
            _ = runLoop.run(mode: .default, before: Date(timeIntervalSinceNow: 1))
            iteration += 1
        } while iteration < timeout
        XCTFail() // FIXME good error message
    }

    private func buildPathCache() {
        func walk(element: PageElement, alreadyWalkedPathToElement: [QueryIdentifier]) {
            let pathOfElement = alreadyWalkedPathToElement + [element.queryIdentifier]
            elementCache[element.elementIdentifier] = CacheEntry(
                application: application,
                path: pathOfElement
            )

            guard let hasChildren = element as? HasChildren else { return }
            for child in hasChildren.elements {
                walk(element: child, alreadyWalkedPathToElement: pathOfElement)
            }
        }

        for element in body.elements {
            walk(element: element, alreadyWalkedPathToElement: [])
        }
    }
}

var elementCache: [PageElementIdentifier: CacheEntry] = [:]

struct CacheEntry {
    let application: String?
    let path: [QueryIdentifier]
}
