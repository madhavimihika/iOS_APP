import Foundation
import Combine

class StatsVM: ObservableObject {
    @Published var sessions: [GameSession] = []
    
    init() {
        loadSessions()
        print(" StatsVM initialized")
    }
    
    func loadSessions() {
        guard let data = UserDefaults.standard.data(forKey: "sessions") else {
            print(" No sessions found in UserDefaults")
            sessions = []
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode([GameSession].self, from: data)
            sessions = decoded
            print(" Loaded \(sessions.count) sessions")
        } catch {
            print(" Failed to decode sessions: \(error)")
            sessions = []
        }
    }
    
    func saveSession(_ session: GameSession) {
        sessions.append(session)
        do {
            let encoded = try JSONEncoder().encode(sessions)
            UserDefaults.standard.set(encoded, forKey: "sessions")
            print("Saved session. Total: \(sessions.count)")
        } catch {
            print(" Failed to save session: \(error)")
        }
    }
    
    func bestScore(for mode: GameMode) -> Int {
        let filtered = sessions.filter { $0.mode == mode }
        return filtered.map { $0.score }.max() ?? 0
    }
    
    func totalGames() -> Int {
        return sessions.count
    }
}
