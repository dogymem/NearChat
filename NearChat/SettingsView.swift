import SwiftUI

struct SettingsView: View {
    @AppStorage("nickname") private var nickname: String = ""
    @State private var newNickname: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Выберите никнейм")
                .font(.title)
            
            TextField("Введите никнейм", text: $newNickname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Сохранить") {
                nickname = newNickname   // сохраняем
            }
            .buttonStyle(.borderedProminent)
            
            if !nickname.isEmpty {
                Text("Ваш никнейм: \(nickname)")
                    .font(.headline)
            }
        }
        .onAppear {
            newNickname = nickname
        }
    }
}

#Preview {
    SettingsView()
}
