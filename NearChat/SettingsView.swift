import SwiftUI

struct SettingsView: View {
    @StateObject var state = AppState()
    @State private var newNickname: String = ""
    @State private var selectedMode: String = "Клиент"
    @State private var connectionStatus: String = ""
    
    var body: some View {
        VStack{
            VStack(spacing: 20) {
                Text("Выберите никнейм")
                    .font(.title)
                
                TextField("Введите никнейм", text: $newNickname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Сохранить") {
                    state.nickname = newNickname   // сохраняем
                }
                .buttonStyle(.borderedProminent)
                
                if !state.nickname.isEmpty {
                    Text("Ваш никнейм: \(state.nickname)")
                        .font(.headline)
                }
            }
            .onAppear {
                newNickname = state.nickname
            }
            
            VStack(spacing: 20) {
                Text("Выберите режим работы")
                    .font(.title)
                
                Picker("Режим", selection: $selectedMode) {
                    Text("Сервер").tag("Сервер")
                    Text("Клиент").tag("Клиент")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedMode == "Сервер" {
                    VStack {
                        Text("IP устройства:")
                            .font(.headline)
                        Text(state.deviceIP.isEmpty ? "Определяется..." : state.deviceIP)
                            .font(.body)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .onAppear {
                        state.deviceIP = getWiFiAddress() ?? "Не удалось определить"
                    }
                } else if selectedMode == "Клиент" {
                    VStack(spacing: 15) {
                        TextField("Введите IP сервера", text: $state.serverIP)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numbersAndPunctuation)
                            .padding(.horizontal)
                        
                        Button("Connect") {
                            connectToServer(ip: state.serverIP)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if !connectionStatus.isEmpty {
                            Text(connectionStatus)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        
    }
    
    
    func connectToServer(ip: String) {
        if ip.isEmpty {
            connectionStatus = "Введите IP"
        } else {
            connectionStatus = "Подключаюсь к \(ip)..."
            // тут позже можно сделать реальное подключение через NWConnection
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                connectionStatus = "Успешно подключено к \(ip)"
            }
        }
    }
    
    func getWiFiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else {
            return nil
        }
        
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) { // IPv4
                let name = String(cString: interface.ifa_name)
                if name == "en0" { // Wi-Fi интерфейс
                    var addr = interface.ifa_addr.pointee
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr,
                                socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname,
                                socklen_t(hostname.count),
                                nil,
                                socklen_t(0),
                                NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
}


#Preview {
    SettingsView()
}
