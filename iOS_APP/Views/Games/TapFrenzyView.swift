// TapFrenzyView.swift
import SwiftUI
internal import _LocationEssentials

struct TapFrenzyView: View {
    @StateObject private var viewModel = TapFrenzyVM()
    @StateObject private var statsVM = StatsVM()
    @StateObject private var locationService = LocationService()
    @Environment(\.dismiss) private var dismiss
    @State private var hasSaved = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                LinearGradient(
                    colors: [Color(hex: "0F172A"), Color(hex: "1E1E38")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Timer Display
                    VStack(spacing: 4) {
                        Text("\(viewModel.timeRemaining)")
                            .font(.system(size: 72, weight: .black, design: .monospaced)) // තවත් පැහැදිලි කලා
                            .foregroundColor(viewModel.timeRemaining <= 3 ? .red : .white)
                            .shadow(color: viewModel.timeRemaining <= 3 ? .red.opacity(0.6) : .clear, radius: 10)
                        
                        Text("seconds")
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    //  Main Tap Button with Premium Gradients
                    Button(action: {
                        viewModel.handleTap()
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: viewModel.gameActive ? [Color.orange, Color(hex: "EA580C")] : [.white.opacity(0.05), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 250, height: 250)
                            .overlay(
                                Circle()
                                    .stroke(viewModel.gameActive ? Color.orange.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 2)
                            )
                            .overlay(
                                VStack(spacing: 8) {
                                    if viewModel.gameActive {
                                        Text("TAP!")
                                            .font(.system(.title, design: .rounded))
                                            .fontWeight(.black)
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.3), radius: 4)
                                        
                                        Text("Score: \(viewModel.score)")
                                            .font(.system(.headline, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white.opacity(0.9))
                                    } else if viewModel.timeRemaining == 0 {
                                        Text("Game Over")
                                            .font(.system(.title3, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(.red)
                                        
                                        Text("Score: \(viewModel.score)")
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                    } else {
                                        Text("Ready?")
                                            .font(.system(.title, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                            )
                            .shadow(color: viewModel.gameActive ? Color.orange.opacity(0.4) : .clear, radius: 20, x: 0, y: 10)
                            .scaleEffect(viewModel.gameActive ? 1.0 : 0.95)
                            .animation(.spring(response: 0.3), value: viewModel.gameActive)
                    }
                    .disabled(!viewModel.gameActive && viewModel.timeRemaining > 0)
                    
                    Spacer()
                    
                    // Action Buttons (Start / Play Again)
                    Group {
                        if !viewModel.gameActive && viewModel.timeRemaining > 0 {
                            Button(action: {
                                viewModel.startGame()
                                hasSaved = false
                            }) {
                                controlButtonLabel(text: "Start Game", color: .orange)
                            }
                        }
                        
                        if viewModel.timeRemaining == 0 && !viewModel.gameActive {
                            Button(action: {
                                viewModel.startGame()
                                hasSaved = false
                            }) {
                                controlButtonLabel(text: "Play Again", color: .orange)
                            }
                        }
                    }
                    
                    // Home Button
                    Button(action: {
                        if viewModel.gameActive {
                            viewModel.endGame()
                        }
                        dismiss()
                    }) {
                        Text("Home")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 24)
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationTitle("Tap Frenzy")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .onAppear {
                locationService.requestPermission()
            }
            .onChange(of: viewModel.gameActive) { _, isActive in
                if !isActive && viewModel.timeRemaining == 0 && !hasSaved {
                    saveGameResult()
                    hasSaved = true
                }
            }
        }
    }
    
    // 💡 Control Buttons වලට Gradient දාන්න වෙනම ලස්සන Subview Component එකක් හැදුවා
    @ViewBuilder
    private func controlButtonLabel(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(.title3, design: .rounded))
            .fontWeight(.bold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.75)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 24)
    }
    
    func saveGameResult() {
        let location = locationService.getLocation()
        let latitude = location?.latitude ?? 0.0
        let longitude = location?.longitude ?? 0.0
        
        let session = GameSession(
            mode: .tap,
            score: viewModel.score,
            timestamp: Date(),
            latitude: latitude,
            longitude: longitude
        )
        statsVM.saveSession(session)
        print(" Saved Tap Frenzy Score: \(viewModel.score)")
    }
}

#Preview {
    TapFrenzyView()
}
