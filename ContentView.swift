import SwiftUI
import Combine

struct ContentView: View {
    @State private var score = 0// variable score(state as said)
    @State private var timeRemaining = 10 //variable timer
    @State private var gameActive = false //boolean

    let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        VStack(spacing: 10) {//layout
//                Image("ss")
//                    .resizable()
//                    .scaledToFit()
            //            }
            
            ZStack{
                Image("ss")
//                   .resizable()ß
                    .scaledToFill()
                    .ignoresSafeArea()
                
            }
            Text("Time: \(timeRemaining)s")//timer
                .font(.largeTitle)
                .fontWeight(.bold)

//game active button
            Button(action: {
                if gameActive {
                    score += 1// score increase
                }
            }) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 500, height: 300)
                    .overlay(
                        Text("Hit Me")//button inside name text
                            .font(.title)
                            .foregroundColor(.yellow)//font colkor set to yellow
                            .bold()
                    )
            }
            Text("Score: \(score)")//Score box
                .font(.title)
                .bold()
            
            Button(gameActive ? "Playing" : "Start Game") {
                startGame()//start game button
                    
            }
            .disabled(gameActive)
        }
        .padding()
        .onReceive(timer) { _ in
            guard gameActive else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                gameActive = false
            }
        }
    }

    func startGame() {
        score = 0
        timeRemaining = 10
        gameActive = true
    }
}

#Preview {
    ContentView()
}
//test
//let s1 = "Hello"
//let s2 = "Swift"
//print(s1 + " " + s2)
//print("\(s1), \(s2)!")
//let word = "Swift"
//print(word.count)
//print(s1.isEmpty)
