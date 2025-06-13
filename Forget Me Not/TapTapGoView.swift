import SwiftUI
import AVFoundation

struct TapTapGoView: View {
    @State private var image: UIImage?
    @State private var detectedLabel = ""
    @State private var objectInfo = ""
    @State private var isDangerous = false
    @State private var showImagePicker = false

    let manager = TapTapGoManager()
    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack(spacing: 20) {
            Text("🧠 Object Identifier")
                .font(.largeTitle.bold())

            Button(action: {
                showImagePicker = true
            }) {
                Label("Tap to Identify", systemImage: "camera")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .cornerRadius(15)
            }

            if !detectedLabel.isEmpty {
                VStack(spacing: 12) {
                    Text("📌 \(detectedLabel)")
                        .font(.title2)
                        .foregroundColor(isDangerous ? .red : .green)

                    Text(objectInfo)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    Button("🔊 Read Aloud") {
                        readAloud()
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
                }
                .padding()
            }

            Spacer()
        }
        .sheet(isPresented: $showImagePicker) {
            CameraImagePicker(selectedImage: $image, isImagePickerPresented: $showImagePicker)
                .onDisappear {
                    if let image = image {
                        detect(image)
                    }
                }
        }
        .padding()
    }

    private func detect(_ image: UIImage) {
        manager.detectObject(in: image) { label, danger, info in
            detectedLabel = label
            isDangerous = danger
            objectInfo = info
        }
    }

    private func readAloud() {
        let utterance = AVSpeechUtterance(string: objectInfo)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}
