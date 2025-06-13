import SwiftUI

struct CareView: View {
    @State private var showMap = false
    
    @State private var selectedClientUID = "REPLACE_WITH_CLIENT_UID"

    var body: some View {
        VStack(spacing: 20) {
            Text("Caregiver Dashboard")
                .font(.largeTitle.bold())

            Button("Track Patient Location") {
                showMap = true
            }
            .font(.title2)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(14)
            .padding(.horizontal)

            // Add other caregiver UI features here...
            Button("Track Patient Location") {
                        showMap = true
                    }
                    .sheet(isPresented: $showMap) {
                        PatientTrackingMapView(clientUID: "CLIENT_UID_HERE") // Replace with actual UID
                    }
            Spacer()
        }
        .sheet(isPresented: $showMap) {
            PatientTrackingMapView(clientUID: selectedClientUID)
        }
    }
}
