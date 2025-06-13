import SwiftUI
import Firebase

@main
struct ForgetMeNotApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView() // or your main view
        }
    }
}
