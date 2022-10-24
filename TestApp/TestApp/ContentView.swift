import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")

                Button(action: {}) {
                    Text("Button in View")
                }
            }
            .padding()
            .navigationBarItems(trailing:                 Button(action: {}) {
                Text("Menu")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
