import XCTest


struct Configuration {
    static var isScreenshottingElements: Bool = false

    static var isLoggingElements: Bool = false
}


public extension XCTestCase {
    var isScreenshottingElements: Bool {
        get { Configuration.isScreenshottingElements }
        set { Configuration.isScreenshottingElements = newValue }
    }

    var isLoggingElements: Bool {
        get { Configuration.isLoggingElements }
        set { Configuration.isLoggingElements = newValue }
    }
}
