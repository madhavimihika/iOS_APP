import SwiftUI

struct ScoreBadge: View {
    let score: Int
    let label: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(score)")
                .font(.title2)
                .fontWeight(.bold)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
