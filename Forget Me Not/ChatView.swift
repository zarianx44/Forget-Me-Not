import SwiftUI

struct ChatView: View {
    @State private var inputText = ""
    @State private var messages: [(String, Bool)] = [] // (text, isUser)

    init() {
        print("💬 ChatView loaded")
    }

    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages.indices, id: \.self) { index in
                            let message = messages[index]
                            HStack {
                                if message.1 {
                                    Spacer()
                                }
                                Text(message.0)
                                    .padding()
                                    .background(message.1 ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                    .frame(maxWidth: 250, alignment: message.1 ? .trailing : .leading)
                                if !message.1 {
                                    Spacer()
                                }
                            }
                            .id(index)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    scrollProxy.scrollTo(messages.count - 1)
                }
            }

            HStack {
                TextField("Type your message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)

                Button("Send") {
                    let userText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !userText.isEmpty else { return }

                    messages.append((userText, true))
                    inputText = ""

                    print("📤 Sending message: \(userText)")

                    ChatAPI.shared.sendMessage(userText) { reply in
                        if let reply = reply {
                            DispatchQueue.main.async {
                                messages.append((reply, false))
                            }
                        } else {
                            DispatchQueue.main.async {
                                messages.append(("Sorry, something went wrong.", false))
                            }
                        }
                    }
                }
                
            

                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Caregiver Chat")
    }
}
