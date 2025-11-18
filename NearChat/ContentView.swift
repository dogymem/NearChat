import SwiftUI

struct ContentView: View {
    @StateObject var state = AppState()
    @StateObject var tcpManager = TCPManager()

    var body: some View {
        // NavigationView теперь внутри каждой вкладки для лучшего управления
        TabView {
            ChatView()
                .environmentObject(state)
                .environmentObject(tcpManager)
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Чат")
                }
            
            SettingsView()
                .environmentObject(state)
                .environmentObject(tcpManager)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Настройки")
                }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
