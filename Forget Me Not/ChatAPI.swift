//
//  ChatAPI.swift
//  Forget Me Not
//
//  Created by Zara on 2025-06-10.
//

import Foundation


struct Message: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Codable {
    let model: String
    let messages: [Message]
}

struct ChatResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

class ChatAPI {
    static let shared = ChatAPI()
    private let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]


    func sendMessage(_ userMessage: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let systemPrompt = Message(role: "system", content: "You are a supportive chatbot for caregivers of dementia patients. Respond with empathy and comfort, but do not give medical advice.")
        let user = Message(role: "user", content: userMessage)
        
        let request = ChatRequest(model: "gpt-4o", messages: [systemPrompt, user])
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONEncoder().encode(request)

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            let result = try? JSONDecoder().decode(ChatResponse.self, from: data)
            DispatchQueue.main.async {
                completion(result?.choices.first?.message.content)
            }
        }.resume()
    }
}

