import SwiftUI

@MainActor
class AppState: ObservableObject {
    @Published var isConnected: Bool = false
    @AppStorage("nickname") var nickname: String = ""
    @Published  var deviceIP: String = ""
    @Published  var serverIP: String = ""
    @Published var selectedMode: String = ""
    @Published var serverPort: String = "12345"
}
