import SwiftUI

struct SettingsView: View {
    @AppStorage("roundDuration") private var roundDuration: Int = 60
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("hapticEnabled") private var hapticEnabled: Bool = true
    @Environment(\.dismiss) private var dismiss
    
    let durationOptions = [30, 60, 90]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Round Length", selection: $roundDuration) {
                        ForEach(durationOptions, id: \.self) { duration in
                            Text("\(duration) seconds")
                                .tag(duration)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Choose how long each round lasts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } header: {
                    Label(" Timer", systemImage: "clock")
                }
                
                Section {
                    Toggle(" Sound Effects", isOn: $soundEnabled)
                    Toggle("haptic Feedback", isOn: $hapticEnabled)
                } header: {
                    Label("🎮Game Settings", systemImage: "gear")
                }
                
                Section {
//                    VStack(alignment: .leading, spacing: 8) {
//                        LevelInfoRow(level: "Level 1", time: "0-15s", cards: "3", lit: "1.5s", color: .green)
//                        LevelInfoRow(level: "Level 2", time: "15-30s", cards: "4", lit: "1.2s", color: .blue)
//                        LevelInfoRow(level: "Level 3", time: "30-45s", cards: "6", lit: "1.0s", color: .purple)
//                        LevelInfoRow(level: "Level 4", time: "45-60s", cards: "9", lit: "0.8s", color: .red)
//                    }
//                    .padding(.vertical, 4)
                } header: {
                    Label("Level Progression", systemImage: "chart.bar")
                } footer: {
                    Text("Levels automatically progress as time passes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    HStack {
                        Text("Games Played")
                        Spacer()
                        Text("\(UserDefaults.standard.integer(forKey: "lightItUpTotalGames"))")
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("High Score")
                        Spacer()
                        Text("\(UserDefaults.standard.integer(forKey: "lightItUpHighScore"))")
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                } header: {
                    Label(" Statistics", systemImage: "chart.line.uptrend.xyaxis")
                }
                
                Section {
                    Button("Reset High Score", role: .destructive) {
                        UserDefaults.standard.set(0, forKey: "lightItUpHighScore")
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                } header: {
                    Label("Danger Zone", systemImage: "exclamationmark.triangle")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
