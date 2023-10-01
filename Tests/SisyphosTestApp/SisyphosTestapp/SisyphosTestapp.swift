import SwiftUI

@main
struct SisyphosTestapp: App {
    var displayedTestView: AnyView {
        registerTestViews()
        let fileName = ProcessInfo.processInfo.arguments[1]
        let lineNumber = Int(ProcessInfo.processInfo.arguments[2])!
        return availableTestViews[Key(fileName: fileName, lineNumber: lineNumber)]!
    }

    var body: some Scene {
        WindowGroup {
            displayedTestView
        }
    }
}


struct Key: Hashable {
    let fileName: String
    let lineNumber: Int
}

var availableTestViews: [Key: AnyView] = [:]

func collect<V: View>(fileName: String, line: Int, @ViewBuilder view: () -> V) {
    let key = Key(fileName: fileName, lineNumber: line)
    availableTestViews[key] = AnyView(view())
}
