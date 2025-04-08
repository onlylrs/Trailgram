//
//  ContentView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var store = MemoryStore()

    var body: some View {
        TabView {
            NavigationStack {
                MapView()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                Text("List View Coming Soon")
            }
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }

            NavigationStack {
                Text("Profile Coming Soon")
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
        .environment(store)
    }
}

#Preview {
    ContentView()
}
