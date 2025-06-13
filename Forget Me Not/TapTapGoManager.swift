import UIKit
import CoreML
import Vision

class TapTapGoManager {
    private let dangerousItems = ["knife", "scissors", "fire", "gas", "chemical", "weapon"]
    private let model = try? TapTapModel(configuration: .init())

    func detectObject(in image: UIImage, completion: @escaping (String, Bool, String) -> Void) {
        guard let pixelBuffer = image.toCVPixelBuffer(),
              let output = try? model?.prediction(image: pixelBuffer) else {
            completion("Unknown", false, "Could not identify the object.")
            return
        }

        let label = output.target
        let confidence = output.targetProbability[label] ?? 0.0
        let isDangerous = dangerousItems.contains { label.lowercased().contains($0) }
        let info = getInfo(for: label)

        print("📸 Detected: \(label) with \(Int(confidence * 100))% confidence")
        completion(label, isDangerous, info)
    }

    func getInfo(for label: String) -> String {
        switch label.lowercased() {
        case "scissors": return "Scissors are sharp tools used to cut. Handle with care."
        case "water bottle": return "A water bottle helps you stay hydrated."
        case "knife": return "Knives are sharp and can be dangerous. Use with caution."
        default: return "No additional info available."
        }
    }
}
