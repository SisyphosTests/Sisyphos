import XCTest
import SwiftUI
import WebKit
import Sisyphos


final class WebViewTests: XCTestCase {
    override func setUp() {
        super.setUp()
        disableDefaultXCUIInterruptionHandlers()
    }

    @available(iOS 26, *)
    func testInAppWebView() {
        launchTestApp {
            if #available(iOS 26, *) {
                WebKit.WebView(url: URL(string: "https://example.com")!)
            }
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                WebView {
                    StaticText("Example Domain")
                }
            }
        }
        ExpectedPage().waitForExistence()
    }

    func testInAppWebViewWithIdentifier() {
        launchTestApp {
            IdentifiableWebView(
                url: URL(string: "https://example.com")!,
                accessibilityId: "my_webview"
            )
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                WebView(identifier: "my_webview")
            }
        }
        ExpectedPage().waitForExistence()
    }

    func testOutOfProcessWebView() {
        launchTestApp {
            AuthSessionTrigger(
                url: URL(string: "https://example.com")!,
                callbackURLScheme: "sisyphostestapp"
            )
        }

        // Handle the "wants to sign in using example.com" system dialog
        let systemDialog = DefaultAlert()
        addUIInterruptionMonitor(page: systemDialog) { dialog in
            dialog.allowButton.tap()
        }

        struct ExpectedPage: Page {
            var body: PageDescription {
                WebView {
                    StaticText("Example Domain")
                }
            }
        }
        ExpectedPage().waitForExistence()
    }
}
