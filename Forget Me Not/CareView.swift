import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestore
import FirebaseAuth

struct CareView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region: MKCoordinateRegion? = nil  // Holds the region for map zooming
    
    var body: some View {
        VStack {
            Text("")
                .font(.title)
                .padding(.bottom, 10)
            
            if let region = locationManager.region ?? self.region {
                Map(coordinateRegion: Binding(
                        get: { region },
                        set: { newRegion in
                            // Only update if not from locationManager to avoid auto-reset
                            if locationManager.region == nil {
                                self.region = newRegion
                            }
                        }
                    ),
                    interactionModes: .all,
                    showsUserLocation: true,
                    annotationItems: locationManager.geofenceCenter.map { [GeofenceLocation(center: $0)] } ?? []
                ) { item in
                    MapAnnotation(coordinate: item.center) {
                        Circle()
                            .stroke(Color.red.opacity(0.8), lineWidth: 2)
                            .frame(width: 100, height: 100)
                    }
                }
                .frame(height: 500)
                .cornerRadius(10)
            } else {
                ProgressView("Getting your location...")
                    .frame(height: 500)
            }
            
            Button("Set Geofence at My Location") {
                if let location = locationManager.locationManager.location {
                    let center = location.coordinate
                    locationManager.setGeofence(center: center)
                    
                    if let user = Auth.auth().currentUser {
                        let db = Firestore.firestore()
                        db.collection("users").document(user.uid).setData([
                            "geofenceCenter": [
                                "lat": center.latitude,
                                "lon": center.longitude
                            ]
                        ], merge: true) { error in
                            if let error = error {
                                print("❌ Error saving geofence: \(error.localizedDescription)")
                            } else {
                                print("✅ Geofence saved to Firestore")
                            }
                        }
                    } else {
                        print("⚠️ No authenticated user")
                    }
                } else {
                    print("⚠️ Current location not available")
                }
            }
            .padding()
            .background(Color.blue.opacity(0.2))
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            if let location = locationManager.locationManager.location {
                let coordinate = location.coordinate
                region = MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // Zoomed in
                )
            }
        }
    }
}

struct GeofenceLocation: Identifiable {
    let id = UUID()
    let center: CLLocationCoordinate2D
}

#Preview {
    CareView()
}
