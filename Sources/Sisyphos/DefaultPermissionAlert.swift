/// A page to interact with iOS' permission dialogue.
public struct DefaultPermissionAlert: Page {
    public let application: String = "com.apple.springboard"

    /// The text which is displayed in the permission dialogue.
    public let permissionText: String?

    /// The button do decline the permission.
    public let disallowButton = Button(label: "Don’t Allow".localizedForSimulator)
    /// The button to allow the permission.
    public let allowButton = Button()

    /// - Parameter permissionText:
    ///     The text which is displayed in the permission dialogue. If you provide a text, then the permission dialogue
    ///     needs to match the text. If you don't provide any text, then any permission dialogue is matched.
    public init(permissionText: String? = nil) {
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
