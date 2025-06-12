//
//  AppRooView.swift
//  Forget Me Not
//
//  Created by Zara on 2025-05-16.
//

import SwiftUI

struct AppRootView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    var body: some View {
        Group {
            if isLoggedIn {
                ContentView()
            } else {
                LoginView()
            }
        }
    }
}
