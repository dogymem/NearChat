
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            TabView {
                ChatView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Chat")
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
            }
        }
    }
}
#Preview {
    ContentView()
}
