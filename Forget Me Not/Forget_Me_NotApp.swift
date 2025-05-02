//
//  Forget_Me_NotApp.swift
//  Forget Me Not
//
//  Created by Zara on 2025-05-01.
//

import SwiftUI

import SwiftUI

import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {

  func application(_ application: UIApplication,

                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

    FirebaseApp.configure()

    return true

  }

}


@main

struct Forget_Me_NotApp: App {

  // register app delegate for Firebase setup

  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


  var body: some Scene {
      

    WindowGroup {

      NavigationView {

        ContentView()

      }

    }

  }

}
