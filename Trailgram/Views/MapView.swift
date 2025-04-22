//
//  MapView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI
import MapKit
/// SpotAnnotation is a custom map annotation view with emoji and title.
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

/// MapView displays all memory spots on a MapKit map.
/// Supports long-press to drop a temporary pin and add a new spot.
/// Includes toolbar button to center on current location and tap-to-select annotation navigation.
struct MapView: View {
    @Environment(MemoryStore.self) var store
    @Environment(FolderStore.self) var folderStore
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var isAddingMemory = false
    @State private var selectedSpot: SelectedSpot? = nil
    @State private var tappedCoordinate: CLLocationCoordinate2D? = nil
    @State private var tappedScreenPoint: CGPoint? = nil
    @State private var showAddFromTap: Bool = false
    @State private var showAddFromButton = false
    @State private var mapProxy: MapProxy? = nil
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            MapReader { proxy in
                
                Map(position: $cameraPosition) {
                    ForEach(folderStore.allSpots) { spot in
                        Annotation(spot.title, coordinate: spot.coordinate) {
                            SpotAnnotation(spot: spot) {
                                if let folderID = folderStore.findFolderID(for: spot) {
                                    selectedSpot = SelectedSpot(spot: spot, folderID: folderID)
                                }
                            }
                        }
                    }
                    
                    // 定义temp spot长什么样
                    if let temp = folderStore.tempSpot {
                        Annotation("Temp Spot", coordinate: temp.coordinate) {
                            VStack {
                                Text("📍")
                            }
                            .padding(6)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                        }
                    }
                    
                }
                .onAppear{
                    mapProxy = proxy
                }
                // 滑动屏幕的时候不会出现add here button
                .onMapCameraChange { _ in
                    if tappedCoordinate != nil {
                            tappedCoordinate = nil
                            tappedScreenPoint = nil
                    }
                }
            }
            // 单击其他地方的时候就把坐标和屏幕点都设为nil，就不会出现add here button
            .gesture(
                TapGesture()
                    .onEnded {
                            tappedCoordinate = nil
                            tappedScreenPoint = nil
                    }
            )
            // 长按识别到一个screen point，通过proxy local转换为坐标
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.3)
                    .sequenced(before: DragGesture(minimumDistance: 0))
                    .onEnded { value in
                        switch value {
                        case .second(true, let drag?):
                            let point = drag.location
                            if let proxy = mapProxy,
                               let coord = proxy.convert(point, from: .local){
                                withAnimation {
                                    tappedCoordinate = coord
                                    tappedScreenPoint = point
                                }
                            }
                        default: break
                        }
                    }
            )

            // 当长按一个位置时这俩变量都会有值，所以弹出add here button，定义了点击这个button就出现temp spot并出现新建表单
            if let point = tappedScreenPoint, let _ = tappedCoordinate {
                Button(action: {
                    if let coord = tappedCoordinate {
                            let tempSpot = MemorySpot(title: "New Spot", description: "", coordinate: coord)
                            folderStore.tempSpot = tempSpot
                    }
                    showAddFromTap = true
                }) {
                    Label("Add Here", systemImage: "plus.circle.fill")
                        .padding(8)
                        .background(.thinMaterial)
                        .cornerRadius(10)
                        .opacity(0.8)
                }
                .position(x: point.x, y: point.y - 40)
                
            }
            
            // 定位按钮
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
        .navigationTitle("Trailgram")
        .navigationBarTitleDisplayMode(.inline)
        // 显示添加spot单
        .sheet(isPresented: $showAddFromTap, onDismiss: {
            tappedCoordinate = nil
            tappedScreenPoint = nil
            folderStore.tempSpot = nil
        }) {
            AddMemoryView(prefillCoordinate: tappedCoordinate)
                .presentationDetents([.fraction(0.33), .large], selection: .constant(.fraction(0.33)))
        }
        
        // 定义右上角+键的作用：把显示创建表单条件设为true，并且自动把图拉回current location
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if let location = CLLocationManager().location {
                        let coord = location.coordinate
                        let tempSpot = MemorySpot(title: "New Spot", description: "", coordinate: coord)
                        folderStore.tempSpot = tempSpot
                        withAnimation {
                            cameraPosition = .region(MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
                        }
                    }
                    showAddFromButton = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        // 创建new spot的表单，消失时让temp spot不显示。
        .sheet(isPresented: $showAddFromButton, onDismiss:{
            folderStore.tempSpot = nil
        }) {
            AddMemoryView(prefillCoordinate: nil)
                .presentationDetents([.large, .fraction(0.33)], selection: .constant(.fraction(0.33)))
                .presentationDragIndicator(.visible)
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
                folderStore.focusCoordinate = nil
            }
        }
        .navigationDestination(item: $selectedSpot) { selected in
            MemorySpotDetailView(spot: selected.spot, parentFolderID: selected.folderID)
        }
        
    }
    
    
    func convertPointToCoordinate(_ point: CGPoint) -> CLLocationCoordinate2D? {
        mapProxy?.convert(point, from: .global)
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
