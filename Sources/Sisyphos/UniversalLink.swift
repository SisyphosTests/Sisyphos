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

        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26 {
            openUniversalLinkIOS26(
                safari: safari,
                dataURL: dataURL,
                timeout: timeout,
                activity: activity,
                file: file,
                line: line
            )
        } else {
            openUniversalLinkLegacy(
                safari: safari,
                dataURL: dataURL,
                timeout: timeout,
                activity: activity,
                file: file,
                line: line
            )
        }
    }
}

// MARK: - iOS 26+

private func openUniversalLinkIOS26(
    safari: XCUIApplication,
    dataURL: String,
    timeout: CFTimeInterval,
    activity: XCTActivity,
    file: StaticString,
    line: UInt
) {
    // iOS 26 Safari uses a CapsuleViewController whose URL bar is a text field with
    // the identifier "TabBarItemTitle". A keyboard from a previously loaded page can hide it,
    // so we dismiss the keyboard on each attempt.
    let tabBarItemTitle = safari.textFields["TabBarItemTitle"]

    let deadline = Date(timeIntervalSinceNow: timeout)
    var foundAddressBar = false
    repeat {
        safari.dismissKeyboard()
        if tabBarItemTitle.waitForExistence(timeout: 1) {
            tabBarItemTitle.tap()
            foundAddressBar = true
            break
        }
    } while Date() < deadline

    guard foundAddressBar else {
        XCTFail("Safari's address bar (TabBarItemTitle) did not appear within \(timeout)s", file: file, line: line)
        return
    }

    // After tapping TabBarItemTitle the screen changes and the actual editable URL bar
    // becomes a text field with the identifier "URL".
    let editableURLField = safari.textFields["URL"]
    guard editableURLField.waitForExistence(timeout: timeout) else {
        XCTFail("Safari's editable URL field did not appear within \(timeout)s", file: file, line: line)
        return
    }

    editableURLField.typeText(dataURL + "\n")

    let link = safari.links["link"]
    guard link.wait(for: \.isHittable, toEqual: true, timeout: timeout) else {
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

    link.waitUntilStablePosition()
    link.tap()
    _ = RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.5))
    // If this is a fresh simulator, then there can be a popup explaining new Safari features and the first tap
    // dismisses the popup instead of opening the link. We can check because a tap on the link also selects it.
    if !link.isSelected {
        link.tap()
    }
}

// MARK: - iOS ≤ 25

private func openUniversalLinkLegacy(
    safari: XCUIApplication,
    dataURL: String,
    timeout: CFTimeInterval,
    activity: XCTActivity,
    file: StaticString,
    line: UInt
) {
    // Safari's address bar appears as a button when a page is loaded, or as a text field when
    // focused/empty. We need to handle both states. A keyboard from a previously loaded page can
    // hide the URL bar, so we dismiss the keyboard on each attempt.
    let urlButton = safari.buttons["URL"]
    let urlTextField = safari.textFields["URL"]

    let deadline = Date(timeIntervalSinceNow: timeout)
    var foundAddressBar = false
    repeat {
        safari.dismissKeyboard()
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
