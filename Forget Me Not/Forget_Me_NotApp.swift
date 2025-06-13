import SwiftUI
import Firebase

@main
struct ForgetMeNotApp: App {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
           WindowGroup {
               if isLoggedIn {
                   ContentView()
               } else {
                   LoginView() // Replace with your actual login view
               }
           }
       }
}
