import MapKit
import SwiftUI

struct CareView: View {
    
    @StateObject var manager = LocationManager()
    
    var body: some View {
        Map(coordinateRegion: $manager.region, showsUserLocation: true)
            .edgesIgnoringSafeArea(.all)
    }
}
