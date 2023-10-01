/// This file contains helpers that are required in both the test app (because there the functionality is needed) and
/// the tests target (because it still needs to compile when we define the SwiftUI views in the tests). Because of this,
/// this file is part of both targets.
import SwiftUI


/// A binding that uses `UIApplication.shared` as backing for its value. This is handy to read values in the test.
func appValueBinding(initialValue: String = "") -> Binding<String> {
    UIApplication.shared.accessibilityLabel = initialValue
    return Binding(
        get: { UIApplication.shared.accessibilityLabel ?? ""},
        set: { value, _ in
            UIApplication.shared.accessibilityLabel = value
        }
    )
}


func binding<Value>(initialValue: Value) -> Binding<Value> {
    var store: Value = initialValue
    return Binding(
        get: { store },
        set: { value, _ in
            store = value
        }
    )
}
