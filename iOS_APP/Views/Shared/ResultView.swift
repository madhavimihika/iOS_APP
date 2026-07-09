import SwiftUI

struct ResultView: View {
    let score: Int
    let gameName: String
    let mode: GameMode
    
    var body: some View {
        VStack(spacing: 30) {
            Text(" Game Over!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Score: \(score)")
                .font(.system(size: 60))
                .fontWeight(.heavy)
                .foregroundColor(.blue)
            
            ShareLink(
                item: "I scored \(score) on \(gameName)! Beat that! 🎮"
            ) {
                Label("Share Your Score", systemImage: "square.and.arrow.up")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}
