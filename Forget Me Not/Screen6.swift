import SwiftUI
import AVFoundation
import Vision
import CoreML

struct Screen6: View {
    @StateObject private var cameraModel = CameraViewModel()
    @State private var resultText = "Looking for object..."
    
    var body: some View {
        ZStack {
            CameraPreview(session: cameraModel.session)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Text("Detected: \(resultText)")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(12)
                    .padding(.bottom, 30)
            }
        }
        .onAppear {
            cameraModel.configure()
            cameraModel.onDetection = { label in
                DispatchQueue.main.async {
                    if label != resultText {
                        resultText = label
                        speak(label) // 🎤 speak result
                    }
                }
            }
        }
        .onDisappear {
            cameraModel.stopSession()
        }
    }
    
    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
