import XCTest


/// The observer which observers which test case is currently running
class UIInterruptionsObserver: NSObject {

    /// The singleton instance which is used withing Sisyphos to do the UI interruption checks and handling of the same.
    static let shared = UIInterruptionsObserver()

    /// Whether or not this observer currently runs a check for existing UI interruptions.
    private(set) var isRunningCheck = false

    /// Whether or not this observer is already installed at the ``XCTest/XCTestObservationCenter``.
    private(set) var isInstalled: Bool = false

    /// The test case which is currently running.
    private var currentTestCase: XCTestCase?

    /// All interruption monitors which have been added and the the test cases for which they were added.
    private var registeredInterruptionMonitors: [(testCase: XCTestCase, monitor: InterruptionMonitor)] = []

    /// The interruption monitors which should be evaluated for the currently running test case.
    private var interruptionMonitorsForCurrentTest: [InterruptionMonitor] {
        registeredInterruptionMonitors.compactMap { (testCase, monitor) in
            guard testCase == currentTestCase else { return nil }
            return monitor
        }
    }

    /// Adds the given UI interruption monitor.
    ///
    /// - Parameters:
    ///   - monitor: The interruption monitor.
    ///   - testCase: The test case for which the interruption monitor should be added. The interruption monitor will
    ///       only be evaluated when tests of this test case are running.
    func addInterruptionMonitor(_ monitor: InterruptionMonitor, for testCase: XCTestCase) {
        registeredInterruptionMonitors.append((
            testCase: testCase,
            monitor: monitor
        ))
    }

    /// Removes the given interruption monitor. It will no longer be evaluated and ignored for the remaining tests.
    ///
    /// - Parameter monitor: The UI interruption monitor which should be removed.
    func removeInterruptionMonitor(_ monitor: InterruptionMonitor) {
        guard let index = registeredInterruptionMonitors.firstIndex(where: { $0.monitor == monitor }) else { return }
        registeredInterruptionMonitors.remove(at: index)
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
        for monitor in interruptionMonitorsForCurrentTest {
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
        currentTestCase = testCase
    }

    func testCaseDidFinish(_ testCase: XCTestCase) {
        currentTestCase = nil
    }
}
