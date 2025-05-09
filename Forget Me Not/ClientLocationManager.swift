import Foundation
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

class ClientLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var region: CLCircularRegion?
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        fetchGeofenceFromFirestore()
    }

    func fetchGeofenceFromFirestore() {
        guard let user = Auth.auth().currentUser else { return }

        Firestore.firestore().collection("users").document(user.uid).getDocument { snapshot, error in
            if let data = snapshot?.data(),
               let geofence = data["geofenceCenter"] as? [String: Any],
               let lat = geofence["lat"] as? CLLocationDegrees,
               let lon = geofence["lon"] as? CLLocationDegrees {

                let center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                let region = CLCircularRegion(center: center, radius: 50, identifier: "caregiverGeofence")
                region.notifyOnExit = true
                region.notifyOnEntry = false
                self.region = region

                self.locationManager.startMonitoring(for: region)
                print("✅ Started monitoring caregiver geofence")
            } else {
                print("⚠️ No geofence found or failed to parse")
            }
        }
    }

    // Handle exiting the region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("🚨 Client exited caregiver geofence!")

        // You can also send a push notification or update Firestore here if needed
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways {
            print("✅ Location authorized")
        } else {
            print("⚠️ Location not authorized")
        }
    }
}
