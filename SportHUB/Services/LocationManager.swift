import CoreLocation
import SwiftUI
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var userLocation: CLLocation?
    
    override init() {
        super.init()
        manager.delegate = self
        
        // PERFORMANCE/VISIBILITY BALANCE:
        
        // 1. Accuracy: 10 meters.
        // Precise enough to see if you are at the court, but doesn't drain battery like "Best".
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // 2. Filter: 10 meters.
        // The map updates only if you move by 10 meters.
        // This eliminates GPS "jitter" and reduces CPU load on the simulator.
        manager.distanceFilter = 10
        
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Take the last available location
        guard let location = locations.last else { return }
        
        // Direct assignment (Without manual filters that might block the first signal)
        self.userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
    }
}
