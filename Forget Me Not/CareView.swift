import SwiftUI
import MapKit

struct CareView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            Text("Geofencing Demo")
                .font(.title)
                .padding(.bottom, 10)
            
            if let region = locationManager.region {
                Map(coordinateRegion: Binding(
                        get: { region },
                        set: { locationManager.region = $0 }
                    ),
                    interactionModes: .all,
                    showsUserLocation: true,
                    annotationItems: locationManager.geofenceCenter.map { [GeofenceLocation(center: $0)] } ?? []) { item in
                        MapAnnotation(coordinate: item.center) {
                            Circle()
                                .stroke(Color.red, lineWidth: 2)
                                .frame(width: 200, height: 200)
                        }
                    }
                    .frame(height: 300)
                    .cornerRadius(10)
            } else {
                ProgressView("Getting your location...")
                    .frame(height: 300)
            }
            
            Button("Set Geofence at My Location") {
                if let location = locationManager.locationManager.location {
                    locationManager.setGeofence(center: location.coordinate)
                } else {
                    print("⚠️ Current location not available")
                }
            }
            .padding()
            .background(Color.blue.opacity(0.2))
            .cornerRadius(10)
        }
        .padding()
    }
}

struct GeofenceLocation: Identifiable {
    let id = UUID()
    let center: CLLocationCoordinate2D
}

#Preview {
    CareView()
}
