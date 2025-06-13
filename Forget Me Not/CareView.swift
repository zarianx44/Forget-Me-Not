import MapKit
import SwiftUI

struct CareView: View {
    @State private var showChat = false  // Track chat view
    @ObservedObject var moodStore: LastMoodStore
    
    var body: some View {

        VStack {
            MoodBannerView(moodStore: moodStore)

                    // other content...
                }
        }
}



