import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
}

class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL = "https://opentdb.com/api.php"
    private let session = URLSession.shared
    
    func fetchQuestions(amount: Int = 10) async throws -> [Question] {
        guard var components = URLComponents(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "amount", value: String(amount)),
            URLQueryItem(name: "type", value: "multiple")
        ]
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.networkError(NSError(domain: "", code: -1))
            }
            
            let decoder = JSONDecoder()
            let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
            return triviaResponse.results
            
        } catch let error as DecodingError {
            throw NetworkError.decodingError
        } catch {
            throw NetworkError.networkError(error)
        }
    }
}
