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

   
    
//    private let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]
    private let apiKey = "***REMOVED***"

    init() {
        print("🔐 API KEY: \(apiKey ?? "nil")")
    }

    func sendMessage(_ userMessage: String, completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        
        let systemPrompt = Message(role: "system", content: "You are a supportive chatbot for caregivers of dementia patients. Respond with empathy and comfort, but do not give medical advice.")
        let user = Message(role: "user", content: userMessage)
        
        let request = ChatRequest(model: "gpt-4", messages: [systemPrompt, user])
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("Bearer \(apiKey ?? "MISSING_KEY")", forHTTPHeaderField: "Authorization")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try? JSONEncoder().encode(request)

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("❌ Request error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("❗ Unexpected status code. Full response: \(String(data: data ?? Data(), encoding: .utf8) ?? "No data")")
                    completion(nil)
                    return
                }
            }

            guard let data = data else {
                print("❌ No data received")
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(ChatResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(result.choices.first?.message.content)
                }
            } catch {
                print("❌ JSON decode error: \(error)")
                print("🔎 Raw response: \(String(data: data, encoding: .utf8) ?? "Unreadable")")
                completion(nil)
            }
        }.resume()
    }

}
