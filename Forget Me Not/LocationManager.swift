import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private var locationManager = CLLocationManager()
    private let db = Firestore.firestore()
    private var userID: String?

    override init() {
        super.init()

        // Get Firebase user ID
        if let currentUser = Auth.auth().currentUser {
            userID = currentUser.uid
        } else {
            print("❌ User not logged in")
            return
        }

        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last, let userID = userID else { return }

        let data: [String: Any] = [
            "latitude": latest.coordinate.latitude,
            "longitude": latest.coordinate.longitude,
            "timestamp": Timestamp(date: Date())
        ]

        db.collection("locations").document(userID).setData(data) { error in
            if let error = error {
                print("❌ Error updating location: \(error.localizedDescription)")
            } else {
                print("✅ Location updated for user \(userID)")
            }
        }
    }
}
