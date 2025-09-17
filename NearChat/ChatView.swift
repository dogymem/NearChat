//
//  ChatView.swift
//  NearChat
//
//  Created by Егор Томашев on 16.09.25.
//

import SwiftUI

struct ChatView: View {
    @StateObject var state = AppState()
    @State private var messages: [String] = []
        @State private var newMessage: String = ""
        
        var body: some View {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages, id: \.self) { msg in
                            Text(msg)
                                .padding(10)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                HStack {
                    TextField("Введите сообщение", text: $newMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: sendMessage) {
                        Text("Отправить")
                            .padding(.horizontal, 10)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
        
        private func sendMessage() {
            guard !newMessage.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            messages.append(newMessage)
            newMessage = ""
        }
    }

#Preview {
    ChatView()
}
