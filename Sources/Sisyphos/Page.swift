import XCTest
import UniformTypeIdentifiers


public protocol Page {
    var application: String? { get }

    @PageBuilder var body: PageDescription { get }
}

public extension Page {
    var application: String? { nil }
}


extension Page {
    /// The name of the page which is displayed to the user, e.g. in error messages or debug output.
    var debugName: String {
        String(describing: type(of: self))
    }
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
        return XCTContext.runActivity(named: "Check if page \(debugName) exists") { activity in
            guard let snapshot = try? xcuiapplication.snapshot() else { return false }
            TestData.isEvaluatingBody = true
            for element in body.elements {
                guard element.exists(in: snapshot) else { return false }
            }
            TestData.isEvaluatingBody = false
            return true
        }
    }

    func waitForExistence(
        timeout: CFTimeInterval = 10,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTContext.runActivity(named: "Wait max \(timeout)s for page \(debugName) to exit") { activity in
            let runLoop = RunLoop.current
            var iteration: CFTimeInterval = 0
            repeat {
                guard !exists() else { return }
                // TODO: checking the UI also took some time already, so this method actually waits longer than the timeout.
                //   Refactor to make it respect the timeout.
                _ = runLoop.run(mode: .default, before: Date(timeIntervalSinceNow: 1))
                iteration += 1
            } while iteration < timeout

            let debugPage = xcuiapplication.currentPage?.generatePageSource()
            if let data = debugPage?.data(using: .utf8) {
                activity.add(
                    XCTAttachment(
                        uniformTypeIdentifier: UTType.swiftSource.identifier,
                        name: "ActualPage.swift",
                        payload: data
                    )
                )
            }

            XCTFail(
                file: file,
                line: line
            ) // FIXME good error message. It should tell which expected elements are missing
        }
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
