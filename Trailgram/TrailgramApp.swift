//
//  TrailgramApp.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI

@main
struct TrailgramApp: App {
    @State private var store = MemoryStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
//            MapView()
//                .environment(store)
        }
    }
}
