//
//  AddMemoryView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI
import CoreLocation

struct AddMemoryView: View {
    @Environment(MemoryStore.self) var store
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var coordinate: CLLocationCoordinate2D?
    // ✅ 新增控制状态
    @State private var showingLocationOptions = false
    @State private var showingSearch = false // 🔜 搜索功能后面实现
    @State private var showingSearchSheet = false
    
    var body: some View {
        Form {
            Section(header: Text("Title")) {
                TextField("Enter a title", text: $title)
            }

            Section(header: Text("Description")) {
                TextEditor(text: $description)
                    .frame(minHeight: 100)
            }

            // ✅ 改为按钮 + 弹窗控制
            Section(header: Text("Location")) {
                Button {
                    showingLocationOptions = true
                } label: {
                    if let coord = coordinate {
                        VStack(alignment: .leading) {
                            Text("📍 Location Selected")
                                .font(.headline)
                            Text("Lat: \(coord.latitude)")
                            Text("Lon: \(coord.longitude)")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("➕ Select Location")
                    }
                }
            }

            Button("Save") {
                saveMemory()
            }
            .disabled(title.isEmpty || coordinate == nil)
            // ✅ 选择方式弹窗
            .confirmationDialog("Choose Location Method", isPresented: $showingLocationOptions) {
                Button("📍 Use Current Location") {
                    Task { await fetchLocation() }
                }
                Button("🔍 Search Location") {
                    showingSearchSheet = true
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .navigationTitle("Add Memory")
        .task {
            await fetchLocation()
        }
        .sheet(isPresented: $showingSearchSheet) {
            LocationSearchView(selectedCoordinate: $coordinate)
        }
    }

    func saveMemory() {
        guard let coord = coordinate else { return }

        let newSpot = MemorySpot(
            title: title,
            description: description,
            coordinate: coord,
            date: Date()
        )

        store.memorySpots.append(newSpot)
        store.focusCoordinate = EquatableCoordinate(coordinate: coord)
        store.hasJustAddedSpot = true
        store.shouldLocateOnLaunch = false
        dismiss()
    }

    func fetchLocation() async {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()

        if let location = manager.location {
            coordinate = location.coordinate
        }
    }
}



#Preview {
//    AddMemoryView()
}
