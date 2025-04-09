//
//  MapView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI
import MapKit
struct SpotAnnotation: View {
    let spot: MemorySpot
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text("📍")
                Text(spot.title)
                    .font(.caption)
                    .bold()
            }
            .padding(6)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}


struct MapView: View {
    @Environment(MemoryStore.self) var store
    @Environment(FolderStore.self) var folderStore

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isAddingMemory = false
    @State private var selectedSpot: SelectedSpot? = nil
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $cameraPosition) {
                ForEach(folderStore.allSpots) { spot in
                    Annotation(spot.title, coordinate: spot.coordinate) {
                        SpotAnnotation(spot: spot) {
                            print("🟢 Annotation clicked: \(spot.title)")
                                if let folderID = folderStore.findFolderID(for: spot) {
                                    selectedSpot = SelectedSpot(spot: spot, folderID: folderID)
                                } else {
                                    print("❌ Folder not found for this spot")
                                }
                        }
                    }
                }
            }
            .ignoresSafeArea()

            // ✅ 添加按钮
            Button(action: {
                Task {
                    await updateUserLocation(force: true)
                }
            }) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 40)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("＋", destination: AddMemoryView())
            }
        }
        .task {
            await updateUserLocation()
        }
        .onChange(of: folderStore.focusCoordinate, initial: false) { _, newValue in
            if let wrapper = newValue {
                let coord = wrapper.coordinate
                withAnimation {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: coord,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    )
                }
                folderStore.focusCoordinate = nil  // ✅ reset
            }
        }
        .navigationDestination(item: $selectedSpot) { selected in
            MemorySpotDetailView(spot: selected.spot, parentFolderID: selected.folderID)
        }
    }

    func updateUserLocation(force: Bool = false) async {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()

        if let location = manager.location {
            if force || (store.focusCoordinate == nil && store.hasJustAddedSpot == false && store.shouldLocateOnLaunch) {
                withAnimation {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    )
                }

                // ✅ 仅在首次加载时关掉
                if store.shouldLocateOnLaunch {
                    store.shouldLocateOnLaunch = false
                }
            } else {
                print("Skip auto-location: logic rejected")
            }
        }
    }
}

#Preview {
//    MapView()
}
