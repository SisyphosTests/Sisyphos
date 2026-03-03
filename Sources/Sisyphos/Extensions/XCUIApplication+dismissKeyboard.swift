import XCTest


extension XCUIApplication {
    func dismissKeyboard() {
        // iOS 26 moved the Done button in a separate toolbar. It's not part of the keyboard anymore.
        if #available(iOS 26, *) {
            let doneButton = toolbars.buttons["Done".localizedForSimulator]
            guard doneButton.exists else { return }
            doneButton.tap()
        } else {
            let dismissButton = keyboards.buttons["Done".localizedForSimulator]
            guard dismissButton.exists else { return }
            // If this is a fresh simulator - which is very common on CI systems - then there's an overlay over the
            // keyboard which explains how to use the swipe keyboard. All of the buttons of the keyboard and its
            // toolbar are visible for the automation, but not tappable. We first need to dismiss the overlay.
            // Unfortunately this overlay is not part of the keyboard, so querying it via application.keyboards... will
            // not work. It doesn't have an accessibility identifier neither.
            if !dismissButton.isHittable {
                for button in buttons.matching(identifier: "Continue".localizedForSimulator).allElementsBoundByIndex {
                    guard button.isHittable else { continue }
                    button.tap()
                    break
                }
            }
            if dismissButton.isHittable {
                dismissButton.tap()
            }
        }
    }
}
