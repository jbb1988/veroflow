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
            locationUpdateHandler?(currentLocation, nil)
        }
    }
    
    // Callback to notify when location is updated
    var locationUpdateHandler: ((CLLocation?, String?) -> Void)?
    
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
        
        // Add reverse geocoding here
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard error == nil, let placemark = placemarks?.first else {
                print("Reverse geocoding failed: \(error?.localizedDescription ?? "")")
                self?.locationUpdateHandler?(location, nil)
                return
            }
            
            // Build a full address string
            let street = placemark.thoroughfare ?? ""
            let subThoroughfare = placemark.subThoroughfare ?? ""
            let city = placemark.locality ?? ""
            let state = placemark.administrativeArea ?? ""
            let postalCode = placemark.postalCode ?? ""
            let country = placemark.country ?? ""
            
            var addressComponents: [String] = []
            let streetAddress = [subThoroughfare, street].filter { !$0.isEmpty }.joined(separator: " ")
            if !streetAddress.isEmpty { addressComponents.append(streetAddress) }
            if !city.isEmpty { addressComponents.append(city) }
            if !state.isEmpty || !postalCode.isEmpty {
                let stateZip = [state, postalCode].filter { !$0.isEmpty }.joined(separator: " ")
                if !stateZip.isEmpty { addressComponents.append(stateZip) }
            }
            if !country.isEmpty { addressComponents.append(country) }
            
            let addressString = addressComponents.joined(separator: ", ")
            
            // Pass both location and address through the location update handler
            DispatchQueue.main.async {
                self?.locationUpdateHandler?(location, addressString)
            }
        }
        
        // Stop updating location after receiving it
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager error: \(error.localizedDescription)")
        currentLocation = nil
        locationUpdateHandler?(nil, nil)
    }
}
