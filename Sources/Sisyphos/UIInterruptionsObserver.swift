import XCTest


/// The observer which observers which test case is currently running
class UIInterruptionsObserver: NSObject {

    /// The singleton instance which is used withing Sisyphos to do the UI interruption checks and handling of the same.
    static let shared = UIInterruptionsObserver()

    /// Whether or not this observer currently runs a check for existing UI interruptions.
    private(set) var isRunningCheck = false

    /// The default interruption monitors which handle system alerts and permission dialogues.
    static var defaultMonitors: [InterruptionMonitor] {
        [
            InterruptionMonitor(page: DefaultPermissionAlert(), handler: {
                DefaultPermissionAlert().disallowButton.tap()
            }),
            InterruptionMonitor(page: DefaultAlert(), handler: {
                DefaultAlert().disallowButton.tap()
            })
        ]
    }

    /// Whether or not this observer is already installed at the ``XCTest/XCTestObservationCenter``.
    private(set) var isInstalled: Bool = false

    /// All interruption monitors which have been added and the the test cases for which they were added.
    private var interruptionMonitors: [(testCase: XCTestCase, monitor: InterruptionMonitor)] = []

    /// The interruption monitors which should be evaluated for the currently running test case.
    private(set) var currentInterruptionMonitors: [InterruptionMonitor] = []

    /// Adds the given UI interruption monitor.
    ///
    /// - Parameters:
    ///   - monitor: The interruption monitor.
    ///   - testCase: The test case for which the interruption monitor should be added. The interruption monitor will
    ///       only be evaluated when tests of this test case are running.
    func addInterruptionMonitor(_ monitor: InterruptionMonitor, for testCase: XCTestCase) {
        interruptionMonitors.append((
            testCase: testCase,
            monitor: monitor
        ))
    }

    /// Removes the given interruption monitor. It will no longer be evaluated and ignored for the remaining tests.
    ///
    /// - Parameter monitor: The UI interruption monitor which should be removed.
    func removeInterruptionMonitor(_ monitor: InterruptionMonitor) {
        guard let index = interruptionMonitors.firstIndex(where: { $0.monitor == monitor }) else { return }
        interruptionMonitors.remove(at: index)
        guard let indexInCurrentMonitors = currentInterruptionMonitors.firstIndex(of: monitor) else { return }
        currentInterruptionMonitors.remove(at: indexInCurrentMonitors)
    }

    /// Evaluates all UI interruption monitors which were added for the currently running test case.
    /// If the interruption monitor reports that the UI is currently interrupted, the monitor's handler is called to
    ///
    /// The handlers are called in the reversed order in which they were added (LIFO), meaning that the interruption
    /// monitor which has been added the latest will be evaluated first.
    func checkForInterruptions() {
        // The handlers of interruption monitors use pages and interact with pages' elements.
        // When they request the elements, this would then trigger another round of `checkForInterruptions()`.
        // That's why we do this check and won't run a second interruption check while one is already running.
        guard !isRunningCheck else { return }

        isRunningCheck = true
        defer {
            isRunningCheck = false
        }
        for monitor in currentInterruptionMonitors + Self.defaultMonitors {
            guard monitor.isCurrentlyInterrupting else { continue }
            monitor.handler()
        }
    }

    /// Adds this observer to the test observation via the `XCTestObservationCenter`.
    func install() {
        assert(!isInstalled)

        XCTestObservationCenter.shared.addTestObserver(self)
        isInstalled = true
    }

}

extension UIInterruptionsObserver: XCTestObservation {

    func testCaseWillStart(_ testCase: XCTestCase) {
        currentInterruptionMonitors = interruptionMonitors.filter { $0.testCase == testCase }.map { $0.monitor }
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        currentInterruptionMonitors = []
    }
}


/// A page to interact with iOS' permission dialogue.
public struct DefaultPermissionAlert: Page {
    public let application: String = "com.apple.springboard"

    /// The text which is displayed in the permission dialogue.
    public let permissionText: String?

    /// The button do decline the permission.
    public let disallowButton = Button(label: "Don’t Allow".localizedForSimulator)
    /// The button to allow the permission.
    public let allowButton = Button()

    /// - Parameter permissionText: The text which is displayed in the permission dialogue.
    init(permissionText: String? = nil) {
        self.permissionText = permissionText
    }

    public var body: PageDescription {
        Alert {
            if let permissionText {
                StaticText(permissionText)
            }
            disallowButton
            allowButton
        }
    }
}


/// A page to interact with other iOS alerts like the App Tracking Transparency prompt.
public struct DefaultAlert: Page {
    public let application: String = "com.apple.springboard"

    /// The text which is displayed in the alert.
    public let textOfAlert: String?

    /// The button to dismiss the alert by declining.
    public let disallowButton = Button()
    /// The button to dismiss the alert by accepting.
    public let allowButton = Button()

    /// - Parameter textOfAlert: The text which is displayed in the alert.
    public init(textOfAlert: String? = nil) {
        self.textOfAlert = textOfAlert
    }

    public var body: PageDescription {
        Alert {
            if let textOfAlert {
                StaticText(textOfAlert)
            }
            disallowButton
            allowButton
        }
    }
}
