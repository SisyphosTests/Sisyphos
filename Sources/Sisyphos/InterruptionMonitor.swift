import Foundation
import XCTest


/// Describes a UI interruption that can happen at undefined times during testing and how to handle it so the tests are
/// unblocked from interacting with the user interface.
public struct InterruptionMonitor {

    /// A unique identifier so we can keep track of the interruption monitor.
    let identifier = UUID()

    /// The page which describes the expected UI interruption. If the pages exists, then it's considered a UI
    /// interruption and the interruption monitor's handler is called.
    public let page: Page
    /// The handler which is called when the interruption described by this UI interruption monitor is blocking the
    /// user interface while testing.
    public let handler: () -> Void

    /// Whether or not the UI interruption monitor is currently
    public var isCurrentlyInterrupting: Bool {
        page.exists().isExisting
    }
}


extension InterruptionMonitor: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
