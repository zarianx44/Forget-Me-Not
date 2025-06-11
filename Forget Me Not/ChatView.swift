//
//  ChatView.swift
//  Forget Me Not
//
//  Created by Zara on 2025-06-10.
//

import Foundation
import SwiftUI

struct ChatView: View {
    @State private var inputText = ""
    @State private var messages: [String] = []

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages.indices, id: \.self) { index in
                    Text(messages[index])
                        .frame(maxWidth: .infinity, alignment: index % 2 == 0 ? .trailing : .leading)
                        .padding()
                        .background(index % 2 == 0 ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }

            HStack {
                TextField("Type your message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Send") {
                    let userText = inputText
                    messages.append(userText)
                    inputText = ""

                    ChatAPI.shared.sendMessage(userText) { response in
                        if let reply = response {
                            messages.append(reply)
                        }
                    }
                }
                .padding()
            }
        }
    }
}
