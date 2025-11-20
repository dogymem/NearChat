import SwiftUI
import Foundation
import SystemConfiguration
import UIKit

struct SettingsView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var tcpManager: TCPManager
    
    @State private var newNickname: String = ""
    
    
    private var statusText: String {
        
        if state.selectedMode == "Сервер", tcpManager.connectionStatus == .listening {
            return "Сервер слушает порт \(state.serverPort)"
        }
        return tcpManager.connectionStatus.description
    }

    
    private var statusColor: Color {
        switch tcpManager.connectionStatus {
        case .idle, .connecting, .stopped:
            return .secondary
        case .connected, .listening:
            return .green
        case .failed, .disconnected:
            return .red
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Настройки пользователя") {
                    TextField("Ваш никнейм", text: $newNickname)
                        .autocorrectionDisabled().textInputAutocapitalization(.never)
                    
                    Button("Сохранить никнейм") {
                        state.nickname = newNickname
                        hideKeyboard()
                    }.disabled(newNickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                Section("Режим работы") {
                    Picker("Режим", selection: $state.selectedMode) {
                        Text("Не выбрано").tag("")
                        Text("Сервер").tag("Сервер")
                        Text("Клиент").tag("Клиент")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: state.selectedMode) { newMode in
                        
                        tcpManager.stop()
                        if newMode == "Сервер" {
                            startServer()
                        }
                    }
                }
                
                if state.selectedMode == "Сервер" {
                    Section("Настройки сервера") {
                        HStack {
                            Text("IP устройства:")
                            Spacer()
                            Text(state.deviceIP.isEmpty ? "Определяется..." : state.deviceIP)
                        }
                        .onAppear {
                            state.deviceIP = getWiFiAddress() ?? "Не удалось определить"
                        }
                        TextField("Порт сервера", text: $state.serverPort).keyboardType(.numberPad)
                    }
                } else if state.selectedMode == "Клиент" {
                    Section("Настройки клиента") {
                        TextField("IP сервера", text: $state.serverIP)
                            .keyboardType(.numbersAndPunctuation)
                            .autocorrectionDisabled().textInputAutocapitalization(.never)
                        
                        TextField("Порт сервера", text: $state.serverPort).keyboardType(.numberPad)
                        
                        HStack {
                            Button("Подключиться") {
                                connectToServer()
                            }
                            .disabled(state.serverIP.isEmpty || state.serverPort.isEmpty || tcpManager.connectionStatus == .connecting)
                        }
                    }
                }
                
                
                if !state.selectedMode.isEmpty {
                    Section("Статус") {
                        Text(statusText)
                            .font(.caption)
                            .foregroundColor(statusColor)
                    }
                }
            }
            .navigationTitle("Настройки")
            .onAppear { newNickname = state.nickname }
        }
    }
    
    private func startServer() {
        guard let port = UInt16(state.serverPort) else {
            print("Некорректный номер порта: \(state.serverPort)")
            tcpManager.connectionStatus = .failed("Неверный порт")
            return
        }
        tcpManager.startServer(port: port)
    }
    
    private func connectToServer() {
        hideKeyboard()
        guard let port = UInt16(state.serverPort) else {
            tcpManager.connectionStatus = .failed("Неверный порт")
            return
        }
        tcpManager.startClient(host: state.serverIP, port: port)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func getWiFiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return nil }
        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ptr.pointee
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) && (String(cString: interface.ifa_name) == "en0") {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
}
