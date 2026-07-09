import SwiftUI
import MapKit
import Combine

struct MapTab: View {

    @StateObject private var statsVM = StatsVM()
    @StateObject private var locationService = LocationService()

    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                UserAnnotation()

                ForEach(statsVM.sessions) { session in
                    Marker(
                        "Score: \(session.score)",
                        coordinate: CLLocationCoordinate2D(
                            latitude: session.latitude,
                            longitude: session.longitude
                        )
                    )
                }
            }
            .navigationTitle("Map")
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .onAppear {
                locationService.requestPermission()
            }
            
            .onChange(of: locationService.currentLocation) { oldValue, newValue in
                if let newLocation = newValue {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: newLocation,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    )
                }
            }
            .overlay {
                if statsVM.sessions.isEmpty {
                    Text("No games played yet!\nPlay a game to see it on the map")
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
        }
    }
}

// 2D Coordinate
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
