import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }
            .sink { [weak self] height in
                DispatchQueue.main.async {
                    self?.keyboardHeight = height
                }
            }
            .store(in: &cancellableSet)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.keyboardHeight = 0
                }
            }
            .store(in: &cancellableSet)
    }
}
