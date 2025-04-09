//
//  ContentView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var store = MemoryStore()
    @State private var folderStore = FolderStore()
    @State private var selectedTab: Tab = .map

    enum Tab {
        case map, list, profile
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                MapView()
                    .tabItem { Label("Map", systemImage: "map") }
                    .tag(Tab.map)

                FolderListView()
                    .tabItem { Label("List", systemImage: "list.bullet") }
                    .tag(Tab.list)

                Text("Profile coming soon")
                    .tabItem { Label("Profile", systemImage: "person") }
                    .tag(Tab.profile)
            }
        }
        .environment(store)
        .environment(folderStore)
    }
}


#Preview {
    ContentView()
}
