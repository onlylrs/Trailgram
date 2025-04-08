//
//  MapView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Environment(MemoryStore.self) var store

    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isAddingMemory = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $cameraPosition) {
                ForEach(store.memorySpots) { spot in
                    Annotation(spot.title, coordinate: spot.coordinate) {
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
        .onChange(of: store.focusCoordinate, initial: false) { _, newValue in
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
                store.focusCoordinate = nil
                // ❗️注意：hasJustAddedSpot 的清除由你控制时机
            }
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
