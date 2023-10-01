import XCTest
import SwiftUI
import Sisyphos
import Photos


final class InterruptionTests: XCTestCase {

    override func setUp() {
        super.setUp()

        XCUIApplication().resetAuthorizationStatus(for: .photos)
        disableDefaultXCUIInterruptionHandlers()
    }

    func testInterruption() {
        launchTestApp {
            Button(action: {
                UIApplication.shared.accessibilityLabel = "Button was pressed"
            }) {
                Text("The Button")
            }
            .alert(
                "Some Alert",
                isPresented: binding(initialValue: true),
                actions: {
                    Button(action: {}) { Text("OK") }
                },
                message: {
                    Text("This is some alert.")
                }
            )
        }

        struct ExpectedInterruption: Page {
            let okButton = Sisyphos.Button(label: "OK")
            var body: PageDescription {
                Alert {
                    StaticText("This is some alert.")
                    okButton
                }
            }
        }

        struct ExpectedPage: Page {
            let button = Sisyphos.Button(label: "The Button")
            var body: PageDescription {
                button
            }
        }

        var wasInterrupted = false
        addUIInterruptionMonitor(page: ExpectedInterruption()) { page in
            wasInterrupted = true
            page.okButton.tap()
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()

        expectedPage.button.tap()

        XCTAssertTrue(wasInterrupted)
    }

    func testSystemPromptWithDefaultHandler() {
        launchTestApp {
            Button(action: {
                UIApplication.shared.accessibilityLabel = "Button was pressed"
            }) {
                Text("The Button")
            }
            .onAppear {
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { _ in }
            }
        }

        var wasInterrupted: Bool = false
        addUIInterruptionMonitor(page: DefaultPermissionAlert()) { permissionAlert in
            wasInterrupted = true
            permissionAlert.disallowButton.tap()
        }

        struct ExpectedPage: Page {
            let button = Sisyphos.Button(label: "The Button")
            var body: PageDescription {
                button
            }
        }
        let expectedPage = ExpectedPage()
        expectedPage.waitForExistence()
        expectedPage.button.tap()

        XCTAssertTrue(wasInterrupted)
    }

    func testDefaultPermissionPromptTapDeny() {
        let app = launchTestApp {
            Text("Test for denying")
                .onAppear {
                    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                        UIApplication.shared.accessibilityLabel = "\(status)"
                    }
                }
        }
        let permissionAlert = DefaultPermissionAlert()
        permissionAlert.waitForExistence()
        permissionAlert.disallowButton.tap()
        XCTAssertEqual("\(PHAuthorizationStatus.denied)", app.label)
    }

    func testDefaultPermissionPromptTapAllow() {
        let app = launchTestApp {
            Text("Test for denying")
                .onAppear {
                    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                        UIApplication.shared.accessibilityLabel = "\(status)"
                    }
                }
        }
        let permissionAlert = DefaultPermissionAlert()
        permissionAlert.waitForExistence()
        permissionAlert.allowButton.tap()
        XCTAssertEqual("\(PHAuthorizationStatus.authorized)", app.label)
    }
}
