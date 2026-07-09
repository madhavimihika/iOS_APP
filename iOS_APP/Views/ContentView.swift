import SwiftUI

struct ContentView: View {
    @StateObject private var locationService = LocationService()
    
    var body: some View {
        TabView {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "gamecontroller")
                }
            
            StatsTab()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
            
            MapTab()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            SettingsTab()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            // Request permission when app launches
            locationService.requestPermission()
        }
    }
}
