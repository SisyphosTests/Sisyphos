import XCTest


public extension XCTestCase {

    /// Adds a new UI interruption monitor.
    ///
    /// Use XCTestCase UI interruption monitors to handle situations in which unrelated UI elements might appear and
    /// block the test’s interaction with elements in the workflow under test. The following situations could result in
    /// a blocked test:
    /// - Your app presents a modal view that takes focus away from the UI under test, as can happen, for example,
    ///   when a background task fails and you notify the user of the failure.
    /// - Your app performs an action that causes the operating system to present a modal UI. An example is an action
    ///   that presents a photo picker, which may make the system request access to photos if the user hasn’t already
    ///   granted it.
    ///
    /// It will add the interruption monitor only to this test case. It will be active for this test case only and will
    /// not influence other test cases.
    ///
    /// Added UI interruption monitors are evaluated in the reversed order in which they were added, meaning that the
    /// UI interruption monitor which has been added the latest will be evaluated first.
    ///
    /// > Note: Unlike XCTest's UI interruption monitor system, Sisyphos will not call all handlers for any UI
    /// > interruption until the first handler returns true. Instead, you can describe how the expected UI interruption
    /// > looks like -- which is not possible in XCTest. Sisysphos then will call only the handlers of those UI
    /// > interruption monitors which are actually blocking the user interaction.
    ///
    /// - Parameters:
    ///   - page: A page which describes the UI interruption. Whenever the page exists, Sisyphos will consider it a UI
    ///       interruption which needs to be removed and will call your provided handler.
    ///   - handler: A handler which is called when the page currently interrupts the user interface. It gets passed an
    ///       instance of the page, so you can interact with its elements to dismiss the interruption.
    ///
    /// - Returns: The created interruption monitor. You can use this created interruption monitor if you want to remove
    ///     it from further evaluation later in the test case by calling ``removeUIInterruptionMonitor(:)``.
    @discardableResult
    func addUIInterruptionMonitor<P: Page>(
        page: P,
        handler: @escaping (P) -> Void
    ) -> InterruptionMonitor {
        if !UIInterruptionsObserver.shared.isInstalled {
            UIInterruptionsObserver.shared.install()
        }
        let interruptionMonitor: InterruptionMonitor = .init(
            page: page,
            handler: { handler(page) }
        )
        UIInterruptionsObserver.shared.addInterruptionMonitor(interruptionMonitor, for: self)
        if isRunning {
            UIInterruptionsObserver.shared.testCaseWillStart(self)
        }

        return interruptionMonitor
    }

    /// Removes the given interruption monitor from this test case. When checking for UI interruptions, Sisyphos will no
    /// longer consider this interruption monitor.
    /// - Parameter monitor: The previously registered interruption monitor which should be removed.
    func removeUIInterruptionMonitor(_ monitor: InterruptionMonitor) {
        UIInterruptionsObserver.shared.removeInterruptionMonitor(monitor)
    }

    /// By default, UI testing in an `XCTestCase` has implicit UI interruption handlers which will dismiss alerts,
    /// permission dialogs, banners and so on. See https://developer.apple.com/videos/play/wwdc2020/10220/?time=209.
    /// Those implicit handlers will interfere if you are setting up tests for permission flows or tests which require
    /// the handling of alerts. Because of this, you can remove this implicit handlers by calling this method.
    func disableDefaultXCUIInterruptionHandlers() {
        addUIInterruptionMonitor(withDescription: "Sisyphos handler") { _ in
            UIInterruptionsObserver.shared.checkForInterruptions()

            // If an interruption monitor handles a UI interruption, then no other UI interruption monitors are called.
            // Because of this, returning true will disable Apple's implicit handlers.
            return true
        }
    }
}


private extension XCTestCase {

    /// Whether or not the test is currently running.
    var isRunning: Bool {
        invocation != nil && testRun?.stopDate == nil
    }
}
