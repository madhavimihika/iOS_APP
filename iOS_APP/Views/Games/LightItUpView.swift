import SwiftUI

// Light It Up View
struct LightItUpView: View {
    // ViewModel
    @StateObject private var vm = LightUpVM()
    
    //Body
    var body: some View {
        ZStack {
            //  Premium Gaming Dark Background
            LinearGradient(
                colors: [Color(hex: "0F172A"), Color(hex: "1E1E38")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                headerView
                    .padding(.top, 10)
                
                Spacer()
                
                gridView
                
                gameInfoView
                
                Spacer()
                
                controlsView
                    .padding(.bottom, 10)
            }
            .padding(.vertical)
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark) 
        .onAppear {
            vm.initializeCards()
        }
        .onDisappear {
            vm.stopGame()
        }
        .overlay(levelUpOverlay)
        .overlay(gameOverOverlay)
    }
    
    // Subviews
    
    private var headerView: some View {
        HStack {
            // Level Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(vm.currentLevel.emoji) \(vm.currentLevel.displayName)")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(vm.currentLevel.color)
                    .shadow(color: vm.currentLevel.color.opacity(0.4), radius: 5)
                
                Text("\(vm.currentLevel.rows)×\(vm.currentLevel.columns)")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Lives
            HStack(spacing: 4) {
                ForEach(0..<vm.maxLives, id: \.self) { index in
                    Image(systemName: index < vm.lives ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .font(.system(size: 18))
                        .shadow(color: index < vm.lives ? .red.opacity(0.5) : .clear, radius: 5)
                }
            }
            
            Spacer()
            
            // Score Card
            HStack(spacing: 4) {
                Text("Score:")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("\(vm.score)")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.black)
                    .scaleEffect(vm.scoreAnimation)
                    .foregroundColor(vm.feedbackType == .correct ? .green :
                                    vm.feedbackType == .wrong ? .red : .white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(0.05))
            .cornerRadius(10)
            
            Spacer()
            
            // Timer
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(vm.timeRemaining)s")
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.black)
                    .foregroundColor(vm.timeRemaining <= 5 ? .red : .white)
                    .shadow(color: vm.timeRemaining <= 5 ? .red.opacity(0.6) : .clear, radius: 5)
                
                Text("\(vm.currentLevel.litWindow, specifier: "%.1f")s lit")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.white.opacity(0.03))
        .background(.ultraThinMaterial.opacity(0.05))
        .cornerRadius(16)
        .padding(.horizontal)
    }
    
    private var gridView: some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), spacing: 12),
                count: vm.currentLevel.columns
            ),
            spacing: 12
        ) {
            ForEach(vm.cards) { card in
                CardView(
                    card: card,
                    isTapped: vm.tappedCardId == card.id,
                    feedbackType: vm.feedbackType,
                    levelColor: vm.currentLevel.color
                )
                .overlay(
                    Group {
                        if card.isLit && vm.currentLevel.cardsToLight == 2 {
                            Text("")
                                .font(.largeTitle)
                                .opacity(0.3)
                        }
                    }
                )
                .onTapGesture {
                    vm.handleCardTap(card: card)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxHeight: CGFloat(vm.currentLevel.rows) * 150)
    }
    
    private var gameInfoView: some View {
        VStack(alignment: .center, spacing: 6) {
            if vm.currentLevel.cardsToLight == 2 {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("2 cards light up at the same time!")
                }
                .font(.system(.caption, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(8)
            }
            
            // Dynamic Custom Feedback
            if vm.feedbackType != .none {
                HStack(spacing: 6) {
                    Image(systemName: vm.feedbackType == .correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                    Text(vm.feedbackType == .correct ? "Correct! +1" : "Wrong! -1")
                }
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(vm.feedbackType == .correct ? .green : .red)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(), value: vm.feedbackType)
            } else {
                Text("\(vm.currentLevel.timeRange) • \(vm.currentLevel.totalCards) cards • \(vm.roundDuration)s round")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal)
    }
    
    private var controlsView: some View {
        VStack(spacing: 12) {
            Button(action: vm.isGameActive ? vm.endGame : vm.startGame) {
                Text(vm.isGameActive ? "End Game" : "Start Game")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: vm.isGameActive ? [.red, Color(hex: "991B1B")] : [vm.currentLevel.color, vm.currentLevel.color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: (vm.isGameActive ? Color.red : vm.currentLevel.color).opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            if !vm.isGameActive && vm.score > 0 {
                VStack(spacing: 4) {
                    Text("Final Score: \(vm.score)")
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if vm.isNewHighScore {
                        Text("🎉 NEW HIGH SCORE! 🎉")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.black)
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.5), radius: 8)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 24)
    }
    
    //Overlays
    
    private var levelUpOverlay: some View {
        Group {
            if vm.showLevelUp {
                VisualEffectBlur(material: .systemUltraThinMaterial) //
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 16) {
                            Text("LEVEL UP! ")
                                .font(.system(size: 32, weight: .black, design: .rounded))
                                .foregroundColor(vm.currentLevel.color)
                                .shadow(color: vm.currentLevel.color.opacity(0.5), radius: 10)
                            
                            Text(vm.currentLevel.displayName)
                                .font(.system(.title2, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("\(vm.currentLevel.rows)×\(vm.currentLevel.columns) • \(vm.currentLevel.litWindow, specifier: "%.1f")s")
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                            
                            if vm.currentLevel.cardsToLight == 2 {
                                Text(" 2 cards light up at once!")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.yellow)
                            }
                        }
                        .padding(.all, 32)
                        .background(.white.opacity(0.05))
                        .background(.ultraThinMaterial)
                        .cornerRadius(24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(vm.currentLevel.color.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 40)
                        .transition(.scale.combined(with: .opacity))
                    )
            }
        }
    }
    
    private var gameOverOverlay: some View {
        Group {
            if vm.showGameOver {
                VisualEffectBlur(material: .dark) //
                    .ignoresSafeArea()
                    .overlay(
                        VStack(spacing: 24) {
                            if vm.lives == 0 {
                                Text("GAME OVER ")
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundColor(.red)
                                    .shadow(color: .red.opacity(0.5), radius: 10)
                                
                                Text("No lives remaining!")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            } else {
                                Text("TIME'S UP! ")
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundColor(.orange)
                                    .shadow(color: .orange.opacity(0.5), radius: 10)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Final Score")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                Text("\(vm.score)")
                                    .font(.system(size: 48, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 8)
                            
                            if vm.isNewHighScore {
                                Text("NEW HIGH SCORE! ")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.black)
                                    .foregroundColor(.yellow)
                                    .shadow(color: .yellow.opacity(0.5), radius: 8)
                            }
                            
                            Button(action: {
                                vm.showGameOver = false
                                vm.startGame()
                            }) {
                                Text("Play Again")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                                    .background(vm.currentLevel.color)
                                    .cornerRadius(14)
                                    .shadow(color: vm.currentLevel.color.opacity(0.4), radius: 8)
                            }
                        }
                        .padding(.all, 32)
                        .background(.white.opacity(0.03))
                        .background(.ultraThinMaterial)
                        .cornerRadius(28)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal, 36)
                        .transition(.scale.combined(with: .opacity))
                    )
            }
        }
    }
}

// MARK: - Blur Helper for Overlays (Fixed renderingMode Error)
struct VisualEffectBlur: UIViewRepresentable {
    var material: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: material))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: material)
    }
}

#Preview {
    NavigationStack {
        LightItUpView()
    }
}
