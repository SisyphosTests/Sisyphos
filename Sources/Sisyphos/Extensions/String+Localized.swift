import Foundation


extension String {

    /// Returns the string localized in the locale of the simulator. This is handy for translating standard UIKit
    /// elements or the keyboard.
    var localizedForSimulator: String {
        Bundle.systemFramework.localizedString(forKey: self, value: "NO TRANSLATION FOUND for \(self)", table: nil)
    }
}


#if canImport(UIKit)
import UIKit

private extension Bundle {

    static var systemFramework: Bundle {
        Bundle(for: UIButton.self)
    }

}
#elseif canImport(AppKit)
import AppKit

private extension Bundle {

    static var systemFramework: Bundle {
        Bundle(for: NSButton.self)
    }

}
#endif
