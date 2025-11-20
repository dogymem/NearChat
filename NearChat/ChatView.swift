import SwiftUI

struct ChatView: View {
    @EnvironmentObject var state: AppState
    @EnvironmentObject var tcpManager: TCPManager

    @State private var newMessage: String = ""

    
    private var isLocked: Bool {
        if state.selectedMode.isEmpty { return true }
        
        if state.selectedMode == "Сервер" {
            
            return tcpManager.connectionStatus != .listening
        }
        
        if state.selectedMode == "Клиент" {
            
            return tcpManager.connectionStatus != .connected
        }
        
        return true
    }
    
    private var isInputFieldDisabled: Bool {
        if state.selectedMode == "Сервер" {
            return tcpManager.connectionStatus != .listening
        }
        if state.selectedMode == "Клиент" {
            return tcpManager.connectionStatus != .connected
        }
        return true
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(tcpManager.messages, id: \.self) { msg in
                            Text(formatMessage(msg))
                                .padding(10)
                                .background(chatBubbleColor(for: msg))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, alignment: chatBubbleAlignment(for: msg))
                                .id(msg)
                        }
                    }
                    .padding()
                    .onChange(of: tcpManager.messages) { _ in
                        if let lastMessage = tcpManager.messages.last {
                            proxy.scrollTo(lastMessage, anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            HStack {
                TextField("Введите сообщение", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isInputFieldDisabled)

                Button("Отправить") {
                    tcpManager.sendMessage(newMessage, state: state)
                    newMessage = ""
                }
                .buttonStyle(.borderedProminent)
                .disabled(isInputFieldDisabled || newMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .blur(radius: isLocked ? 3 : 0)
        .overlay(isLocked ? lockOverlay : nil)
        .animation(.easeInOut(duration: 0.3), value: isLocked)
        
    }

    
    private var lockOverlay: some View {
        Color.black.opacity(0.4).ignoresSafeArea()
            .overlay(
                VStack(spacing: 10) {
                    Image(systemName: "lock.fill").font(.system(size: 40)).foregroundColor(.white.opacity(0.8))
                    Text(lockOverlayText()).font(.title3).foregroundColor(.white).multilineTextAlignment(.center).padding(.horizontal, 16)
                }.padding(24).background(Color.black.opacity(0.6)).cornerRadius(16).shadow(radius: 10)
            )
    }
    
    private func lockOverlayText() -> String {
        if state.nickname.isEmpty { return "Введите никнейм на вкладке 'Настройки'" }
        if state.selectedMode.isEmpty { return "Выберите режим работы в Настройках" }
        
        switch tcpManager.connectionStatus {
        case .listening:
            return "Сервер запущен и ожидает клиентов..." 
        case .connecting:
            return "Подключение к серверу..."
        case .failed(let error):
            return "Не удалось подключиться: \(error)"
        case .disconnected(let reason):
            return reason ?? "Отключено от сервера"
        default:
             if state.selectedMode == "Клиент" {
                return "Подключитесь к серверу в Настройках"
             } else if state.selectedMode == "Сервер" {
                return "Запустите сервер в Настройках"
             }
             return "Проверьте настройки"
        }
    }

    private func formatMessage(_ fullMessage: String) -> String {
        let parts = fullMessage.split(separator: ":", maxSplits: 2).map(String.init)
        guard parts.count == 3, let timeInterval = TimeInterval(parts[0]) else { return fullMessage }
        let timestamp = Date(timeIntervalSince1970: timeInterval)
        let dateStr = DateFormatter.localizedString(from: timestamp, dateStyle: .short, timeStyle: .short)
        let nickname = String(data: Data(base64Encoded: parts[1]) ?? Data(), encoding: .utf8) ?? "?"
        let message = String(data: Data(base64Encoded: parts[2]) ?? Data(), encoding: .utf8) ?? "?"
        return "[\(dateStr)] \(nickname): \(message)"
    }
    
    private func chatBubbleColor(for fullMessage: String) -> Color {
        let parts = fullMessage.split(separator: ":", maxSplits: 2).map(String.init)
        guard parts.count == 3, let receivedNickname = String(data: Data(base64Encoded: parts[1]) ?? Data(), encoding: .utf8) else { return .gray.opacity(0.2) }
        
        if receivedNickname == "Система" { return .orange.opacity(0.2) }
        return receivedNickname == state.nickname ? .blue.opacity(0.2) : .gray.opacity(0.2)
    }
    
    private func chatBubbleAlignment(for fullMessage: String) -> Alignment {
        let parts = fullMessage.split(separator: ":", maxSplits: 2).map(String.init)
        guard parts.count == 3, let receivedNickname = String(data: Data(base64Encoded: parts[1]) ?? Data(), encoding: .utf8) else { return .leading }
        
        if receivedNickname == "Система" { return .center }
        return receivedNickname == state.nickname ? .trailing : .leading
    }
}
