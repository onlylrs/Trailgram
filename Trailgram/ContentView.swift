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
    @State private var userVM = UserViewModel()

    enum Tab {
        case map, list, profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            // ✅ Map 页面独立 NavigationStack
            NavigationStack {
                MapView()
            }
            
            .tabItem {
                Label("Map", systemImage: "map")
            }
            .tag(Tab.map)

            // ✅ List 页面独立 NavigationStack
            NavigationStack {
                FolderListView()
            }
            .tabItem {
                Label("List", systemImage: "list.bullet")
            }
            .tag(Tab.list)
            
            NavigationStack {
                TravelPosterView()
            }
            .tabItem {
                Label("Poster", systemImage: "star")
            }
            .tag(Tab.list)

            // ✅ Profile 页面（可以不包 NavigationStack）
            ProfileView(userVM: userVM)
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(Tab.profile)
        }
        .environment(store)
        .environment(folderStore)
    }
}


#Preview {
    ContentView()
}
