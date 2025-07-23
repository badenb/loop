import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var userLocation: CLLocationCoordinate2D?
    
    private let movementThreshold: CLLocationDistance = 10
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = movementThreshold
        manager.requestWhenInUseAuthorization()
        print("🔔 Requested location authorization")
        
        if manager.authorizationStatus == .authorizedWhenInUse
            || manager.authorizationStatus == .authorizedAlways {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("🔔 Authorization status changed: \(manager.authorizationStatus.rawValue)")

        switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                print("✅ Authorized — starting location updates")
                manager.startUpdatingLocation()

            case .denied, .restricted:
                print("❌ Location permission denied or restricted")

            default:
                break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("📍 Received location updates: \(locations)")

        guard let loc = locations.last else { return }
        
        if let prev = userLocation {
            let prevLoc = CLLocation(latitude: prev.latitude, longitude: prev.longitude)
            let distanceMoved = loc.distance(from: prevLoc)
            guard distanceMoved >= movementThreshold else { return }
        }
        
        if let loc = locations.first {
            DispatchQueue.main.async {
                self.userLocation = loc.coordinate
                print("✅ Published user location: \(self.userLocation!)")
            }
        }
    }
}
