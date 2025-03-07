import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    var currentLocation: CLLocation? {
        didSet {
            // Notify observers of location update
            locationUpdateHandler?(currentLocation)
        }
    }
    
    // Callback to notify when location is updated
    var locationUpdateHandler: ((CLLocation?) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // Request location permission
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Fetch current location
    func fetchCurrentLocation() {
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager error: \(error.localizedDescription)")
        currentLocation = nil
    }
}