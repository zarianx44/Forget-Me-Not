import MapKit
import SwiftUI

struct CareView: View {
    @StateObject var manager = LocationManager()
    @State private var showChat = false  // Track chat view

    var body: some View {
        ZStack {
            Map(coordinateRegion: $manager.region, showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showChat = true
                    }) {
                        Image(systemName: "message.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showChat) {
            ChatView()
        }
    }
}
