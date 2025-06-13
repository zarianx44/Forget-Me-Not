import SwiftUI

struct CareView: View {
    @ObservedObject var moodStore: LastMoodStore
    @State private var quote = QuoteProvider.currentQuote()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    MoodBannerView(moodStore: moodStore)

                    VStack(spacing: 16) {
                        Text(quote)
                            .font(.system(size: 28, weight: .semibold))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Refresh Quote") {
                            quote = QuoteProvider.randomQuote()
                        }
                        .font(.caption)
                    }

                    VStack(spacing: 20) {
                        CareFeatureButton(title: "Breathing Exercise", icon: "wind", iconColor: .blue) {
                            BreathingView()
                        }

                        CareFeatureButton(title: "Gratitude Journal", icon: "heart.text.square", iconColor: .pink) {
                            GratitudeJournalView()
                        }

                        CareFeatureButton(title: "Quick Self-Check", icon: "waveform.path.ecg", iconColor: .green) {
                            SelfCheckView()
                        }

                        CareFeatureButton(title: "Guided Reflection", icon: "books.vertical", iconColor: .orange) {
                            ReflectionView()
                        }
                        CareFeatureButton(title: "Daily Chat Check-In", icon: "message", iconColor: .purple) {
                            ChatCheckInView()
                        }

                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
            }
        }
    }
}

// MARK: - Feature Button
struct CareFeatureButton<Destination: View>: View {
    var title: String
    var icon: String
    var iconColor: Color
    var destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding()
                    .background(Circle().fill(iconColor))

                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Quote Provider
struct QuoteProvider {
    static let quotes = [
        "You are doing better than you think.",
        "Small steps every day lead to big changes.",
        "Take care of yourself—your work is important.",
        "You can't pour from an empty cup. Rest is productive.",
        "Progress, not perfection.",
        "Breathe. You’ve got this.",
        "Your care makes a difference.",
        "Even on hard days, you are strong.",
        "Every act of care is a ripple of love.",
        "You deserve kindness too."
    ]

    static func currentQuote() -> String {
        let index = Calendar.current.component(.hour, from: Date()) % quotes.count
        return quotes[index]
    }

    static func randomQuote() -> String {
        quotes.randomElement() ?? quotes.first!
    }
}

// MARK: - Breathing View (Centered)
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
            Spacer()

            Text(phase == .holdAfterExhale ? "Hold" : phase.rawValue)
                .font(.largeTitle.bold())
                .transition(.opacity)

            ZStack {
                Circle()
                    .fill(RadialGradient(gradient: Gradient(colors: [.blue, .purple]), center: .center, startRadius: 50, endRadius: 200))
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 4), value: scale)

                Text("\(countdown)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .onAppear { startPhase() }
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
            scale = (phase == .exhale) ? 1.0 : 1.5
        }
    }
}

// MARK: - Gratitude Journal
struct GratitudeJournalView: View {
    @AppStorage("gratitudeEntries") private var savedEntries: String = ""
    @State private var newEntry: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Gratitude Journal")
                .font(.largeTitle.bold())

            TextField("I’m grateful for...", text: $newEntry)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button("Add Entry") {
                guard !newEntry.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                let updated = [newEntry] + entries
                savedEntries = updated.joined(separator: "|")
                newEntry = ""
            }
            .buttonStyle(.borderedProminent)

            List {
                ForEach(entries, id: \.self) { entry in
                    Text("• \(entry)")
                }
            }
        }
        .padding()
    }

    var entries: [String] {
        savedEntries.split(separator: "|").map(String.init)
    }
}

// MARK: - Self Check (with timestamp + comments)
struct SelfCheckView: View {
    @AppStorage("stressLevel") private var stressLevel: Double = 5
    @AppStorage("energyLevel") private var energyLevel: Double = 5
    @AppStorage("selfCheckLog") private var selfCheckLog: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Quick Self-Check")
                .font(.largeTitle.bold())

            Text("You're doing your best — take a deep breath. 💛")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            VStack(alignment: .leading) {
                Text("Stress Level: \(Int(stressLevel))")
                Slider(value: $stressLevel, in: 0...10)
                    .accentColor(.red)
            }

            VStack(alignment: .leading) {
                Text("Energy Level: \(Int(energyLevel))")
                Slider(value: $energyLevel, in: 0...10)
                    .accentColor(.green)
            }

            Button("Log Check-In") {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                let timestamp = formatter.string(from: Date())
                let entry = "\(timestamp):\(Int(stressLevel)),\(Int(energyLevel))"
                let updatedLog = [entry] + selfCheckEntries
                selfCheckLog = updatedLog.prefix(10).joined(separator: "|")
            }
            .buttonStyle(.borderedProminent)

            Divider()
                .padding(.top)

            Text("🗓️ Recent Check-Ins")
                .font(.title2.bold())
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(selfCheckEntries, id: \.self) { log in
                        let parts = log.split(separator: ":")
                        if parts.count == 2 {
                            let time = String(parts[0])
                            let values = parts[1].split(separator: ",").compactMap { Int($0) }
                            if values.count == 2 {
                                let stress = values[0]
                                let energy = values[1]

                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(time)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)

                                        HStack {
                                            Label("Stress: \(stress)", systemImage: "flame.fill")
                                                .padding(6)
                                                .background(Color.red.opacity(0.2))
                                                .cornerRadius(8)

                                            Label("Energy: \(energy)", systemImage: "bolt.fill")
                                                .padding(6)
                                                .background(Color.green.opacity(0.2))
                                                .cornerRadius(8)
                                        }
                                        .font(.callout)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }

    var selfCheckEntries: [String] {
        selfCheckLog.split(separator: "|").map(String.init)
    }
}


// MARK: - Guided Reflection
struct ReflectionView: View {
    @AppStorage("reflectionText") private var reflection: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Guided Reflection")
                .font(.largeTitle.bold())

            Text("How did today go?")
                .font(.headline)

            TextEditor(text: $reflection)
                .frame(height: 200)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3)))

            Spacer()
        }
        .padding()
    }
}

import SwiftUI

struct ChatCheckInView: View {
    @State private var navigateToReflection = false
    private let reflectionTriggerIndex = 3 // "Want to reflect on anything?" step

    struct ChatStep: Identifiable {
        let id = UUID()
        let prompt: String
        let options: [String]
        let followUp: [String: String]? // Optional: if option chosen, show this message
    }

    @AppStorage("chatResponses") private var savedResponses: String = ""

    @State private var responses: [String] = []
    @State private var currentIndex: Int = 0
    @State private var showSummary = false
    @State private var followUpText: String? = nil

    private let steps: [ChatStep] = [
        ChatStep(
            prompt: "Hey, how was your day?",
            options: ["Good 😊", "Okay 😐", "Bad 😞"],
            followUp: [
                "Bad 😞": "I’m really sorry to hear that. You’re carrying a lot — be gentle with yourself 💛.",
                "Okay 😐": "That’s totally okay. Some days are just… okay. You still showed up 💪.",
                "Good 😊": "That’s wonderful! I’m glad today had some bright spots ☀️."
            ]
        ),
        ChatStep(
            prompt: "Did you feel supported today?",
            options: ["Yes", "Somewhat", "Not really"],
            followUp: [
                "Not really": "That’s tough. Please remember, you're not alone — asking for help is brave. 💙",
                "Somewhat": "Partial support still counts. Keep reaching out, you deserve full care. 🤝",
                "Yes": "Having a support system is so important. Keep shining!"
            ]
        ),
        ChatStep(
            prompt: "Did you take time for yourself?",
            options: ["Yes", "No", "Trying to"],
            followUp: [
                "No": "Even 5 quiet minutes can help. Maybe now’s a good time to pause.",
                "Trying to": "You're trying, and that's already self-care in motion 💖.",
                "Yes": "Great job! Everyone needs some time to themselves. keep it up, you're doing great. "
            ]
        ),
        ChatStep(
            prompt: "Want to reflect on anything?",
            options: ["Yes", "No", "Maybe later"],
            followUp: nil
        ),
        ChatStep(
            prompt: "Before you go — you’re doing amazing. One step at a time 💫",
            options: ["Thank you", "I needed that", "Okay "],
            followUp: nil
        )

    ]

    var body: some View {
        VStack(spacing: 24) {
            if showSummary {
                Text("Thank you for checking in")
                    .font(.title2.bold())
                    .padding(.top)

                ForEach(0..<steps.count, id: \.self) { i in
                    VStack(alignment: .leading) {
                        Text("**\(steps[i].prompt)**")
                        Text("Answer: \(responses[i])")
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 4)
                }

                Button("Done") {
                    currentIndex = 0
                    responses = []
                    showSummary = false
                    followUpText = nil
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)

            } else {
                Text(steps[currentIndex].prompt)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()

                if let followUp = followUpText {
                    Text(followUp)
                        .font(.body.italic())
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 12) {
                    ForEach(steps[currentIndex].options, id: \.self) { option in
                        Button(option) {
                            
                            responses.append(option)

                            // Handle follow-up message if applicable
                            if let followUps = steps[currentIndex].followUp,
                               let message = followUps[option] {
                                followUpText = message
                            } else {
                                followUpText = nil
                            }

                            // Delay before next step
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                if currentIndex == reflectionTriggerIndex && option == "Yes" {
                                    navigateToReflection = true
                                } else {
                                    advance()
                                }
                            }


                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }

            Spacer()
            
            NavigationLink(
                destination: ReflectionView(),
                isActive: $navigateToReflection,
                label: { EmptyView() }
            )
            .hidden()

        }
        .padding()
        .animation(.easeInOut, value: currentIndex)
    }

    private func advance() {
        if currentIndex + 1 < steps.count {
            currentIndex += 1
        } else {
            saveResponses()
            showSummary = true
        }
    }


    private func saveResponses() {
        let timestamp = Int(Date().timeIntervalSince1970)
        let record = "\(timestamp):\(responses.joined(separator: ","))"
        let logs = savedResponses.split(separator: "|").map(String.init)
        savedResponses = ([record] + logs).prefix(10).joined(separator: "|")
    }
}
