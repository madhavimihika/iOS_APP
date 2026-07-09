import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var currentLocation: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let manager = CLLocationManager()
    private var hasRequested = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Deprecated
        self.authorizationStatus = manager.authorizationStatus
        print("📍 LocationService initialized")
    }
    
    func requestPermission() {
        guard CLLocationManager.locationServicesEnabled() else {
            print(" Location services disabled")
            return
        }
        
        //  instance property
        let status = manager.authorizationStatus
        print("📍 Status: \(status.rawValue)")
        
        if status == .notDetermined && !hasRequested {
            hasRequested = true
            print(" Requesting permission...")
            manager.requestWhenInUseAuthorization()
        } else if status == .denied || status == .restricted {
            print("Permission denied")
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            print(" Already authorized")
            manager.startUpdatingLocation()
        }
    }
    
    func getLocation() -> CLLocationCoordinate2D? {
        return manager.location?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // UI updates main thread
        DispatchQueue.main.async {
            self.currentLocation = locations.last?.coordinate
            print("📍 Location updated: \(String(describing: self.currentLocation))")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        DispatchQueue.main.async {
            self.authorizationStatus = status
            print("📍 Status changed: \(status.rawValue)")
            
            switch status {
            case .authorizedWhenInUse, .authorizedAlways:
                print(" LOCATION AUTHORIZED!")
                manager.startUpdatingLocation()
            case .denied, .restricted:
                print("Location denied!")
            case .notDetermined:
                print(" Still not determined")
                break
            @unknown default:
                break
            }
        }
    }
}


