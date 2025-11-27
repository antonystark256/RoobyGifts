import Foundation

// MARK: - DATA MODELS
struct AIGiftSuggestion: Identifiable, Codable, Hashable {
    var id: UUID = UUID()
    let item: String
    let description: String
    let price_range: String
    
    enum CodingKeys: String, CodingKey {
        case item, description, price_range
    }
}

// MARK: - GEMINI SERVICE
class GeminiService {
    static let shared = GeminiService()
    
    // ⚠️ INSERT YOUR API KEY HERE
    private let apiKey = "AIzaSyA64dB7fiTRzuDi2bvQa2yhGlrR8svlZG8"
    private let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent"
    
    private init() {}
    
    func generateGiftIdeas(
        age: String,
        gender: String,
        budget: String,
        event: String,
        interests: String,
        character: String
    ) async throws -> [AIGiftSuggestion] {
        
        guard let url = URL(string: "\(urlString)?key=\(apiKey)") else {
            throw URLError(.badURL)
        }
        
        let prompt = """
        You are an expert gift consultant. Suggest 5 creative and specific gift ideas based on this profile:
        - Age: \(age)
        - Gender: \(gender)
        - Budget: \(budget)
        - Occasion: \(event)
        - Interests: \(interests)
        - Personality: \(character)
        
        Strictly output ONLY a JSON array. Do not use Markdown formatting. Do not write "Here is the JSON".
        Format:
        [
            {
                "item": "Name of the gift",
                "description": "Short explanation why it fits (max 15 words)",
                "price_range": "Approx price (e.g. $20-50)"
            }
        ]
        """
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return try parseGeminiResponse(data)
    }
    
    private func parseGeminiResponse(_ data: Data) throws -> [AIGiftSuggestion] {
        // Parse the complex Gemini JSON structure to get the text part
        struct GeminiResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable {
                        let text: String
                    }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]?
        }
        
        let apiResponse = try JSONDecoder().decode(GeminiResponse.self, from: data)
        
        guard let text = apiResponse.candidates?.first?.content.parts.first?.text else {
            throw URLError(.cannotParseResponse)
        }
        
        // Clean up markdown code blocks if Gemini ignores instructions
        let cleanText = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleanText.data(using: .utf8) else {
            throw URLError(.dataNotAllowed)
        }
        
        return try JSONDecoder().decode([AIGiftSuggestion].self, from: jsonData)
    }
}
