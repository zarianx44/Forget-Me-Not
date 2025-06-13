import SwiftUI
import AVFoundation
import AudioToolbox

struct TapTapGoView: View {
    @State private var image: UIImage?
    @State private var detectedLabel = ""
    @State private var objectInfo = ""
    @State private var isDangerous = false
    @State private var showImagePicker = false
    @State private var showDangerAlert = false

    let manager = TapTapGoManager()
    let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        ZStack {
            (isDangerous ? Color.red : Color(.systemBackground))
                .ignoresSafeArea()
                .animation(.easeInOut, value: isDangerous)

            VStack(spacing: 30) {
                Text("Object Identifier")
                    .font(.system(size: 42, weight: .heavy))
                    .foregroundColor(Color.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                Text("Use your camera to scan an object and receive detailed safety information.")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                Button(action: {
                    showImagePicker = true
                }) {
                    Text("Identify Object")
                        .font(.system(size: 28, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal)

                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 280)
                        .cornerRadius(20)
                        .padding(.horizontal)
                }

                if !detectedLabel.isEmpty {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Detected Object")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.primary)

                        Text(detectedLabel)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(isDangerous ? .white : .green)

                        Text("Object Details")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.primary)

                        ScrollView {
                            Text(objectInfo.isEmpty ? "No information available for this object." : objectInfo)
                                .font(.system(size: 22))
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                        }
                        .frame(minHeight: 100, maxHeight: 200)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(14)

                        Button("Read Out Loud") {
                            readAloud()
                        }
                        .font(.system(size: 24, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.3))
                        .foregroundColor(.primary)
                        .cornerRadius(15)
                    }
                    .padding()
                }

                Spacer()
            }
        }
        .sheet(isPresented: $showImagePicker) {
            CameraImagePicker(selectedImage: $image, isImagePickerPresented: $showImagePicker)
                .onDisappear {
                    if let image = image {
                        detect(image)
                    }
                }
        }
        .alert("⚠️ Warning", isPresented: $showDangerAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This object may be dangerous.\nPlease use caution.")
        }
    }

    private func detect(_ image: UIImage) {
        manager.detectObject(in: image) { label, danger, info in
            DispatchQueue.main.async {
                print("Label: \(label), Danger: \(danger), Info: \(info)")

                detectedLabel = label
                isDangerous = danger
                objectInfo = info

                if danger {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    readAloud()
                    showDangerAlert = true
                }
            }
        }
    }

    private func readAloud() {
        let message = "\(detectedLabel). \(objectInfo)"
        let utterance = AVSpeechUtterance(string: message)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        synthesizer.speak(utterance)
    }
}
