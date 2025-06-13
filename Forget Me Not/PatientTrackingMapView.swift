import SwiftUI
import MapKit
import FirebaseFirestore

struct PatientTrackingMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.4219999, longitude: -122.0840575),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State private var patientLocation: CLLocationCoordinate2D?
    
    let clientUID: String
    let db = Firestore.firestore()

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: patientLocation.map { [PatientAnnotation(coordinate: $0)] } ?? []) { annotation in
                MapMarker(coordinate: annotation.coordinate, tint: .red)
            }
            .edgesIgnoringSafeArea(.all)

            if patientLocation == nil {
                VStack {
                    Spacer()
                    Text("Waiting for patient location...")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding()
                }
            }
        }
        .onAppear {
            listenForLocationUpdates()
        }
    }

    func listenForLocationUpdates() {
        db.collection("locations").document(clientUID)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data(),
                      let lat = data["latitude"] as? CLLocationDegrees,
                      let lon = data["longitude"] as? CLLocationDegrees else {
                    print("No location found.")
                    return
                }

                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                patientLocation = coordinate
                region.center = coordinate
            }
    }
}

struct PatientAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
