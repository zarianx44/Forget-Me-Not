import SwiftUI


struct CareView: View {
    @State private var showBreathing = false
    @ObservedObject var moodStore: LastMoodStore
    @State private var showMap = false 
    
    @State private var selectedClientUID = "REPLACE_WITH_CLIENT_UID"

    var body: some View {
        VStack(spacing: 40) {
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

        VStack {
            MoodBannerView(moodStore: moodStore)

            NavigationLink("Breathing Exercise") {
                BreathingView()
            }

        }
        .padding()
        
        }
}


import SwiftUI

struct BreathingView: View {
    @Environment(\.dismiss) var dismiss

    @State private var phase: BreathPhase = .inhale
    @State private var countdown: Int = 4
    @State private var scale: CGFloat = 1.0

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum BreathPhase: String {
        case inhale = "Inhale"
        case hold = "Hold"
        case exhale = "Exhale"
        case holdAfterExhale = "HoldAfterExhale"

        var next: BreathPhase {
            switch self {
            case .inhale: return .hold
            case .hold: return .exhale
            case .exhale: return .holdAfterExhale
            case .holdAfterExhale: return .inhale
            }
        }
    }

    var body: some View {
        VStack(spacing: 40) {

            Text(phase == .holdAfterExhale ? "Hold" : phase.rawValue)
                .font(.largeTitle.bold())
                .transition(.opacity)


            ZStack {
                Circle()
                    .fill(
                        RadialGradient(gradient: Gradient(colors: [.blue, .purple]), center: .center, startRadius: 50, endRadius: 200)
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 4), value: scale)

                Text("\(countdown)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .onAppear {
            startPhase()
        }
        .onReceive(timer) { _ in
            if countdown > 1 {
                countdown -= 1
            } else {
                phase = phase.next
                startPhase()
            }
        }
    }

    private func startPhase() {
        countdown = 4

        withAnimation(.easeInOut(duration: 4)) {
            switch phase {
            case .inhale:
                scale = 1.5
            case .hold, .holdAfterExhale:
                scale = 1.5
            case .exhale:
                scale = 1.0
            }
        }
    }
}
