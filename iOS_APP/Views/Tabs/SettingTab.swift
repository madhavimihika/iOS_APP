import SwiftUI

struct SettingsTab: View {
    @State private var notificationTime = Date()
    @State private var notificationsEnabled = true
    @State private var showResetAlert = false
    @StateObject private var statsVM = StatsVM()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("🔔 Notifications") {
                    Toggle("Enable Daily Challenge", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        DatePicker("Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .onChange(of: notificationTime) { _, newTime in
                                NotificationService.shared.scheduleDailyNotification(at: newTime)
                            }
                    }
                }
                
                Section(" Data") {
                    Button("Reset All Stats", role: .destructive) {
                        showResetAlert = true
                    }
                    .alert("Are you sure?", isPresented: $showResetAlert) {
                        Button("Delete All", role: .destructive) {
                            UserDefaults.standard.removeObject(forKey: "sessions")
                            statsVM.loadSessions()
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }
                
                Section(" About") {
                    Text("TheRealApp v1.0")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                NotificationService.shared.requestPermission()
            }
        }
    }
}
