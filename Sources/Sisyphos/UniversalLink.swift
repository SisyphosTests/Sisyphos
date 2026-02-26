import XCTest


/// Opens a universal link by navigating Safari to a data URL containing the link, then tapping it.
///
/// This is the standard technique for testing universal links in UI tests, since universal link
/// resolution cannot be triggered programmatically from within an app.
///
/// - Parameters:
///   - universalLink: The universal link URL to open (e.g. `"https://example.com/path"`).
///   - timeout: How long to wait (in seconds) for Safari elements to appear. Defaults to `10`.
///   - file: The file where the failure occurs. The default is the filename of the test case
///     where you call this function.
///   - line: The line number where the failure occurs. The default is the line number where you
///     call this function.
public func open(
    universalLink: String,
    timeout: CFTimeInterval = 10,
    file: StaticString = #file,
    line: UInt = #line
) {
    XCTContext.runActivity(named: "Open universal link \(universalLink)") { activity in
        let safari = XCUIApplication(bundleIdentifier: "com.apple.mobilesafari")
        safari.launch()

        let html = "<a href=\"\(universalLink)\">link</a>"
        guard let encodedHTML = html.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            XCTFail("Failed to percent-encode the universal link HTML page", file: file, line: line)
            return
        }
        let dataURL = "data:text/html," + encodedHTML

        // Safari's address bar appears as a button when a page is loaded, or as a text field when
        // focused/empty. We need to handle both states.
        let urlButton = safari.buttons["URL"]
        let urlTextField = safari.textFields["URL"]

        let deadline = Date(timeIntervalSinceNow: timeout)
        var foundAddressBar = false
        repeat {
            if urlButton.waitForExistence(timeout: 1) {
                urlButton.tap()
                foundAddressBar = true
                break
            }
            if urlTextField.exists {
                urlTextField.tap()
                foundAddressBar = true
                break
            }
        } while Date() < deadline

        guard foundAddressBar else {
            XCTFail("Safari's address bar did not appear within \(timeout)s", file: file, line: line)
            return
        }

        // After tapping the button the address bar becomes a text field.
        guard urlTextField.waitForExistence(timeout: timeout) else {
            XCTFail("Safari's URL text field did not appear within \(timeout)s", file: file, line: line)
            return
        }

        urlTextField.typeText(dataURL + "\n")

        let link = safari.links["link"]
        guard link.waitForExistence(timeout: timeout) else {
            let screenshot = XCTAttachment(screenshot: safari.screenshot())
            screenshot.name = "Safari – universal link not found"
            screenshot.lifetime = .keepAlways
            activity.add(screenshot)
            XCTFail(
                "The universal link did not appear in Safari within \(timeout)s",
                file: file,
                line: line
            )
            return
        }

        link.tap()
    }
}
