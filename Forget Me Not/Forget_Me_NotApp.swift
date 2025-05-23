//
//  Forget_Me_NotApp.swift
//  Forget Me Not
//
//  Created by Zara on 2025-05-01.
//

import SwiftUI
import FirebaseCore

// ✅ AppDelegate to configure Firebase early
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        print("✅ Configuring Firebase...")
        FirebaseApp.configure()
        return true
    }
}

// ✅ Root App Entry Point
@main
struct Forget_Me_NotApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                ContentView() // or your main user view
            } else {
                LoginView()   // or onboarding/sign-in view
            }
        }
    }
}
