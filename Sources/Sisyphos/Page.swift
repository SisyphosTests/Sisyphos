import XCTest
import UniformTypeIdentifiers


/// A page describes a screen that is expected to appear in the tests. It's the basic building block for writing tests
/// with Sisyphos.
public protocol Page {

    /// The bundle identifier of the pages' application.
    ///
    /// You can use this property to test and interact with other apps.
    ///
    /// If you set this property to an empty string (`""`), then the target application of your tests' target is used.
    ///
    /// Usually you don't need to implement this property as long as you have properly set up your test target to have a
    /// target application. Then a a default implementation is provided which sets the bundle identifier to the empty
    /// string, therefore using the app which is configured as the tests' target application.
    var application: String { get }

    /// Describes the expected contents of the screen.
    @PageBuilder var body: PageDescription { get }
}

public extension Page {
    var application: String { "" }
}


extension Page {
    /// The name of the page which is displayed to the user, e.g. in error messages or debug output.
    var debugName: String {
        String(describing: type(of: self))
    }
}

extension Page {
    var xcuiapplication: XCUIApplication {
        if !application.isEmpty {
            return XCUIApplication(bundleIdentifier: application)
        } else {
            return XCUIApplication()
        }
    }
}


public extension Page {

    /// Checks if the given page exists, that means it's currently visible on the screen as described in the page
    /// description.
    func exists() -> PageExistsResults {
        XCTContext.runActivity(named: "Check if page \(debugName) exists") { activity in
            UIInterruptionsObserver.shared.checkForInterruptions()

            let screenshotAttachment = XCTAttachment(screenshot: xcuiapplication.screenshot())
            screenshotAttachment.lifetime = .deleteOnSuccess
            activity.add(screenshotAttachment)

            let queryWebViewSnapshots = snapshotQueryWebViews()
            guard let snapshot = try? xcuiapplication.snapshot() else {
                return PageExistsResults(
                    missingElements: body.elements,
                    actualPage: nil
                )
            }
            let additionalWebViews = outOfProcessWebViewSnapshots(appSnapshot: snapshot, queryWebViewSnapshots: queryWebViewSnapshots)
            let finder = ElementFinder(page: self, snapshot: snapshot, additionalWebViews: additionalWebViews)
            TestData.isEvaluatingBody = true
            defer {
                TestData.isEvaluatingBody = false
            }
            return PageExistsResults(
                missingElements: finder.check(),
                actualPage: snapshot.toPage()
            )
        }
    }

    /// Checks if the given page exists, that means it's currently visible on the screen as described in the page
    /// description.
    ///
    /// If it doesn't exist, the currently running test is failed automatically.
    ///
    /// - Parameters:
    ///   - timeout:
    ///       How long Sisyphos should wait (in seconds) until the non-existence of the page will cause a test failure.
    ///       You should choose a balance between slow loading pages (e.g. if the screen depends on a content that is
    ///       loaded from a slow server) and your test's total execution time.
    ///   - file:
    ///       The file where the failure occurs. You usually don't provide this value. The default is the filename of
    ///       the test case where you call this function.
    ///   - line:
    ///       The line number where the failure occurs. You usually don't provide this value. The default is the line
    ///       number where you call this function.
    ///
    /// > Note:
    ///    If you want to check if a page exists without failing the currently running test, you can use the
    ///    ``exists()`` method. It will not fail the test and give a result that you can introspect to find out which
    ///    elements of a page are missing.
    func waitForExistence(
        timeout: CFTimeInterval = 15,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        XCTContext.runActivity(named: "Wait max \(timeout)s for page \(debugName) to exist") { activity in
            let runLoop = RunLoop.current
            let deadline = Date(timeIntervalSinceNow: timeout)
            var results: PageExistsResults?
            repeat {
                let currentResults = exists()
                guard !currentResults.isExisting else { return }
                results = currentResults
                _ = runLoop.run(mode: .default, before: Date(timeIntervalSinceNow: 1))
            } while Date() < deadline

            if let data = results?.actualPage?.generatePageSource().data(using: .utf8) {
                activity.add(
                    XCTAttachment(
                        uniformTypeIdentifier: UTType.swiftSource.identifier,
                        name: "ActualPage.swift",
                        payload: data
                    )
                )
            }

            XCTFail(
                "Page \(debugName) didn't exist after \(timeout)s"
                + (results?.failureDescription ?? ""),
                file: file,
                line: line
            )
        }
    }
}

extension Page {
    func refreshElementCache() {
        let queryWebViewSnapshots = snapshotQueryWebViews()
        guard let snapshot = try? xcuiapplication.snapshot() else {
            return
        }
        let additionalWebViews = outOfProcessWebViewSnapshots(appSnapshot: snapshot, queryWebViewSnapshots: queryWebViewSnapshots)
        let finder = ElementFinder(page: self, snapshot: snapshot, additionalWebViews: additionalWebViews)
        _ = finder.check()
    }
}

extension Page {
    /// Snapshots all web views found via `xcuiapplication.webViews` query upfront.
    /// Called *before* `xcuiapplication.snapshot()` so that both snapshots are taken as close together
    /// as possible, minimizing the window for accessibility tree changes between them.
    func snapshotQueryWebViews() -> [XCUIElementSnapshot] {
        xcuiapplication.webViews.allElementsBoundByIndex.compactMap { try? $0.snapshot() }
    }
}


/// Identifies out-of-process web views by comparing pre-collected query-based web view snapshots
/// against web views found in the app's snapshot tree. Web views present in the query but not
/// matched in the snapshot tree are out-of-process (e.g. SFSafariViewController,
/// ASWebAuthenticationSession).
func outOfProcessWebViewSnapshots(
    appSnapshot: XCUIElementSnapshot,
    queryWebViewSnapshots: [XCUIElementSnapshot]
) -> [XCUIElementSnapshot] {
    guard !queryWebViewSnapshots.isEmpty else { return [] }

    let snapshotWebViews = collectWebViewSnapshots(from: appSnapshot)

    return queryWebViewSnapshots.filter { querySnapshot in
        let isInSnapshot = snapshotWebViews.contains {
            $0.matches(snapshot: querySnapshot)
        }
        return !isInSnapshot
    }
}

private func collectWebViewSnapshots(from snapshot: XCUIElementSnapshot) -> [XCUIElementSnapshot] {
    var result: [XCUIElementSnapshot] = []
    if snapshot.elementType == .webView {
        result.append(snapshot)
    }
    for child in snapshot.children {
        result.append(contentsOf: collectWebViewSnapshots(from: child))
    }
    return result
}

var elementPathCache: [PageElementIdentifier: CacheEntry] = [:]

struct CacheEntry {
    let page: Page
    let snapshot: XCUIElementSnapshot?
}


private extension PageExistsResults {
    var failureDescription: String {
        missingElements.map {
            "\n⛔️ missing element \(type(of: $0)), defined at \($0.elementIdentifier.file) \($0.elementIdentifier.line):\($0.elementIdentifier.column)"
        }.joined()
    }
}
