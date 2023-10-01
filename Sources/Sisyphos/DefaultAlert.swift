/// A page to interact with other iOS alerts like the App Tracking Transparency prompt.
public struct DefaultAlert: Page {
    public let application: String = "com.apple.springboard"

    /// The text which is displayed in the alert.
    public let textOfAlert: String?

    /// The button to dismiss the alert by declining.
    public let disallowButton = Button()
    /// The button to dismiss the alert by accepting.
    public let allowButton = Button()

    /// - Parameter textOfAlert: The text which is displayed in the alert. If you provide a text, then the alert needs
    ///     to match the text. If you don't provide any text, then any alert is matched.
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
