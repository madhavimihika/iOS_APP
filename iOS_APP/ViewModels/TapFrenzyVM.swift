import Foundation
import Combine

class TapFrenzyVM: ObservableObject {
    @Published var score = 0
    @Published var timeRemaining = 10
    @Published var gameActive = false
    
    private var timer: Timer?
    
    func startGame() {
        score = 0
        timeRemaining = 10
        gameActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.gameActive = false
                self.timer?.invalidate()
                self.timer = nil
            }
        }
    }
    
    func handleTap() {
        if gameActive {
            score += 1
        }
    }
    
    func endGame() {
        gameActive = false
        timer?.invalidate()
        timer = nil
    }
}
