import Foundation

class TriviaService {
    // MARK: - Singleton
    static let shared = TriviaService()
    
    private init() {}  
    
    private let baseURL = "https://opentdb.com/api.php"
    
    func fetchQuestions(amount: Int = 10) async throws -> [Question] {
        guard let url = URL(string: "\(baseURL)?amount=\(amount)&type=multiple") else {
            throw TriviaError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        let response = try decoder.decode(TriviaResponse.self, from: data)
        
        return response.results
    }
}

// MARK: - Response Models
struct TriviaResponse: Codable {
    let responseCode: Int
    let results: [Question]
    
    enum CodingKeys: String, CodingKey {
        case responseCode = "response_code"
        case results
    }
}

enum TriviaError: Error {
    case invalidURL
    case noData
    case decodingError
}
