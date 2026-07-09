import SwiftUI

struct HomeTab: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Premium Gaming Dark Gradient Background
                LinearGradient(
                    colors: [Color(hex: "0F172A"), Color(hex: "1E1E38")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) {
                        
                        //  Header Section
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(.blue.opacity(0.15))
                                    .frame(width: 140, height: 140)
                                    .blur(radius: 20)
                                
                                Image(systemName: "moon.stars.fill")
                                    .font(.system(size: 80))
                                    .symbolRenderingMode(.multicolor)
                                    .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                            }
                            
                            Text("Mini Games")
                                .font(.system(size: 38, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Choose a game to play")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(.gray.opacity(0.8))
                        }
                        .padding(.top, 40)
                        
                        //Navigation Links / Game Buttons
                        VStack(spacing: 18) {
                            NavigationLink(destination: QuizRushView()) {
                                AppButton(
                                    title: "Quiz Rush",
                                    subtitle: "10 trivia questions",
                                    icon: "person.crop.circle",
                                    color: .blue
                                )
                            }
                            
                            NavigationLink(destination: TapFrenzyView()) {
                                AppButton(
                                    title: "Tap Frenzy",
                                    subtitle: "Tap as fast as you can!",
                                    icon: "hand.thumbsup",
                                    color: .orange
                                )
                            }
                            
                            NavigationLink(destination: LightItUpView()) {
                                AppButton(
                                    title: "Light It Up",
                                    subtitle: "Tap the lights before time runs out",
                                    icon: "lightbulb.fill",
                                    color: .purple
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                        
                        // Footer
                        Text("Week 4 Assessment - All 3 apps working!")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                            .padding(.bottom, 20)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar) // navigationBarHidden(true)
        }
    }
}

// Reusable Modern App Button
struct AppButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 18) {
            // Icon Background
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 55, height: 55)
                
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            // Texts
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.regular)
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "chevron.right.circle.fill")
                .font(.title3)
                .foregroundColor(.white.opacity(0.3))
        }
        .padding(.all, 16)
        //  Modern Frosted Glass Effect
        .background(.white.opacity(0.06))
        .background(.ultraThinMaterial.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.15), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

//Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 1)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
