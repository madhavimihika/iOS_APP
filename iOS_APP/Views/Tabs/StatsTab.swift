import SwiftUI
import Charts

struct StatsTab: View {
    @StateObject private var statsVM = StatsVM()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    Text("Total Games: \(statsVM.totalGames())")
                    Text("Best Tap: \(statsVM.bestScore(for: .tap))")
                    Text("Best Light: \(statsVM.bestScore(for: .light))")
                    Text("Best Quiz: \(statsVM.bestScore(for: .quiz))")
                }
                
                Section("Scores by Game") {
                    Chart {
                        ForEach(GameMode.allCases, id: \.self) { mode in
                            BarMark(
                                x: .value("Game", mode.rawValue),
                                y: .value("Best Score", statsVM.bestScore(for: mode))
                            )
                            .foregroundStyle(by: .value("Mode", mode.rawValue))
                        }
                    }
                    .frame(height: 200)
                }
            }
            .navigationTitle("Stats")
            .refreshable {
                statsVM.loadSessions()
            }
        }
    }
}
