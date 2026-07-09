import Foundation
import CoreLocation

struct GameSession: Codable, Identifiable {
    var id = UUID()
    let mode: GameMode
    let score: Int
    let timestamp: Date
    let latitude: Double
    let longitude: Double
}
