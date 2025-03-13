import CoreLocation
import Foundation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    
    private let locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = kCLDistanceFilterNone
        manager.pausesLocationUpdatesAutomatically = false
        return manager
    }()
    
    private var locationStatus: CLAuthorizationStatus?
    
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
        locationStatus = locationManager.authorizationStatus
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Request location permission
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Fetch current location
    func fetchCurrentLocation() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied or restricted")
            currentLocation = nil
        case .notDetermined:
            requestLocationPermission()
        @unknown default:
            print("Unknown location authorization status")
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        // Stop updating location after receiving it
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager error: \(error.localizedDescription)")
        currentLocation = nil
    }
}
