//
//  TriviaService.swift
//  iOS_APP
//

import Foundation

// MARK: - Errors
enum TriviaError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case apiError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .noData: return "No data received"
        case .decodingError: return "Failed to decode response"
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .apiError(let code): return "API error code: \(code)"
        }
    }
}

// TRIUVIA SERVICE
class TriviaService {
    private let baseURL = "https://opentdb.com/api.php"
    
    //fetch from API
    func fetchQuestions(amount: Int = 10) async throws -> [Question] {
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "amount", value: String(amount)),
            URLQueryItem(name: "type", value: "multiple")
        ]
        
        guard let url = components.url else {
            print(" Invalid URL")
            throw TriviaError.invalidURL
        }
        
        print(" Fetching from API: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print(" Bad response")
            throw TriviaError.networkError(NSError(domain: "", code: -1))
        }
        
        print("Data received: \(data.count) bytes")
        
        do {
            let decoder = JSONDecoder()
            let triviaResponse = try decoder.decode(TriviaResponse.self, from: data)
            
            guard triviaResponse.responseCode == 0 else {
                print(" API error code: \(triviaResponse.responseCode)")
                throw TriviaError.apiError(triviaResponse.responseCode)
            }
            
            print("Decoded \(triviaResponse.results.count) questions from API")
            return triviaResponse.results
        } catch {
            print("Decoding error: \(error)")
            throw TriviaError.decodingError
        }
    }
    
    //Load from Local JSON (Fallback)
    func loadLocalQuestions() -> [Question]? {
        print("Loading from local JSON (fallback)...")
        
        // Try multiple paths
        let possibleNames = ["triviaAPP", "Components/triviaAPP", "triviaAPP.json"]
        
        for name in possibleNames {
            let fileName = name.hasSuffix(".json") ? String(name.dropLast(5)) : name
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                continue
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let response = try decoder.decode(TriviaResponse.self, from: data)
                print("Loaded \(response.results.count) questions from local JSON")
                return response.results
            } catch {
                print(" Failed to decode JSON: \(error)")
            }
        }
        
        print("No local JSON found")
        return nil
    }
    
    //API with Local Fallback
    func fetchQuestionsWithFallback(amount: Int = 10) async -> [Question] {
        print(" Attempting to fetch from API...")
        
        // Try API first
        do {
            let questions = try await fetchQuestions(amount: amount)
            if !questions.isEmpty {
                print("API successful! Loaded \(questions.count) questions")
                return questions
            }
        } catch {
            print("API failed: \(error.localizedDescription)")
        }
        
        // Fallback to local JSON
        print(" Falling back to local JSON...")
        if let localQuestions = loadLocalQuestions() {
            print("Local JSON loaded: \(localQuestions.count) questions")
            return localQuestions
        }
        
        print("All sources failed")
        return []
    }
}
