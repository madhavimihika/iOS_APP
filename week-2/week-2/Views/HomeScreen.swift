import SwiftUI

struct HomeScreen: View {
    @AppStorage("lightItUpHighScore") private var highScore: Int = 0
    @AppStorage("lightItUpTotalGames") private var totalGames: Int = 0
    @AppStorage("roundDuration") private var roundDuration: Int = 60
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(" Light It Up")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(roundDuration)s rounds • 4 Levels")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(
                            Circle()
                                
                                .fill(Color.gray.opacity(0.15))
                        )
                }
                
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 40)
            
            Spacer()
            
            VStack(spacing: 20) {
                NavigationLink(destination: LightItUpViewLevel1()) {
                    GameModeButton(
                        title: "🟢 Level 1",
                        subtitle: "3 Cards • 1.5s • 0-15s",
                        color: .green
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: LightItUpViewLevel2()) {
                    GameModeButton(
                        title: "🔵 Level 2",
                        subtitle: "4 Cards • 1.2s • 15-30s",
                        color: .blue
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: LightItUpViewLevel3()) {
                    GameModeButton(
                        title: "🟣 Level 3",
                        subtitle: "6 Cards • 1.0s • 30-45s",
                        color: .purple
                    )
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: LightItUpViewLevel4()) {
                    GameModeButton(
                        title: "🔴 Level 4",
                        subtitle: "9 Cards • 0.8s • 2x Lit ⚡⚡",
                        color: .red
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            VStack(spacing: 4) {
                HStack(spacing: 20) {
                    Label(" \(highScore)", systemImage: "trophy.fill")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    
                    Label("\(totalGames)", systemImage: "gamecontroller.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Label(" \(roundDuration)s", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("High Score • Games Played • Round Length")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle("")
        #if os(iOS)
       
        .navigationBarHidden(true)
        #endif
        .background(
            LinearGradient(
                
                colors: [.black, Color.gray.opacity(0.1)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct GameModeButton: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.gradient)
                .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
        )
    }
}
