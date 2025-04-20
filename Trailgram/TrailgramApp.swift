//
//  TrailgramApp.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//
import Firebase
import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct TrailgramApp: App {
    
    @State private var store = MemoryStore()
    
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var session = UserSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
