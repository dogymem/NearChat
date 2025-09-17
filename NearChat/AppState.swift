import SwiftUI

class AppState: ObservableObject {
    @Published var isConnected: Bool = false
    @AppStorage("nickname") var nickname: String = ""
    @Published  var deviceIP: String = ""
    @Published  var serverIP: String = ""
}
