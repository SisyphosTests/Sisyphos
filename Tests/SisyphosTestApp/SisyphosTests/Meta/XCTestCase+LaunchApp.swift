import XCTest
import SwiftUI


extension XCTestCase {
    /// Launches the test app and the test app will display the given SwiftUI view hierarchy.
    ///
    /// > Note: It's not really possible to send SwiftUI view instances to the test app. The test app runs in a
    ///     different process. So this is a hack on top of a hack. What we do is that we simply take the file and
    ///     line number from where this method is called and pass it to the test app as launch arguments. The test app
    ///     knows the source code of the SwiftUI views that were defined in this file at this line in this method call.
    ///     It knows it from the `TestCodeGenerator.swift` parser which parses the source code of all SwiftUI views in
    ///     the tests and copies them together with the meta information (file, line) into the test app. So the tests
    ///     and the test app both contain identical copies of the source of the SwiftUI views. Then the test app can
    ///     create instances of the SwiftUI views that have the exact same syntax.
    @discardableResult
    func launchTestApp<V: View>(
        @ViewBuilder swiftUI: () -> V,
        file: StaticString = #file,
        line: UInt = #line
    ) -> XCUIApplication {
        let rootDirectory = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .path
        let fileString = String(describing: file)
        guard fileString.hasPrefix(rootDirectory) else { preconditionFailure() }
        let app = XCUIApplication()
        app.launchArguments = [String(fileString.dropFirst(rootDirectory.count)), String(line)]
        app.launch()

        return app
    }
}
