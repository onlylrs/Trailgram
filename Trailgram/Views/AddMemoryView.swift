//
//  AddMemoryView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI
import CoreLocation

struct AddMemoryView: View {
    @Environment(FolderStore.self) var folderStore
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var note: String = ""
    @State private var useCurrentLocation: Bool = true
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var selectedFolderID: UUID?
    @State private var showSearchView = false
    @State private var showFolderPicker = false
    @State private var readableAddress: String = ""
    var prefillCoordinate: CLLocationCoordinate2D? = nil
    
    init(prefillCoordinate: CLLocationCoordinate2D? = nil) {
            self._selectedCoordinate = State(initialValue: prefillCoordinate)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack {
                Text("New Spot")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
            }
            .padding()
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter a title", text: $title)
                }
                
                Section(header: Text("Note")) {
                    TextEditor(text: $note)
                        .frame(height: 100)
                }
                
                Section(header: Text("Location")) {
                    Button("Use Current Location") {
                        requestCurrentLocation()
                    }
                    
                    Button("Search Location") {
                        showSearchView = true
                    }
                    
                    if let coord = selectedCoordinate {
                        Label(readableAddress, systemImage: "mappin.and.ellipse")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }
                
                
                Section(header: Text("Choose Folder")) {
                    Button {
                        showFolderPicker = true
                    } label:{
                        Text(folderStore.name(for: selectedFolderID) ?? "Select Folder")
                            .foregroundStyle(.orange)
                    }
                }
                
                
                Section {
                    Button("Save Memory Spot") {
                        save()
                        dismiss()
                    }
                    .disabled(title.isEmpty || selectedCoordinate == nil || selectedFolderID == nil)
                }
            }
            .onAppear {
                if let coord = selectedCoordinate {
                    reverseGeocode(coord) { address in
                        readableAddress = address
                    }
                } else {
                    requestCurrentLocation()
                }
                
                if selectedFolderID == nil {
                    selectedFolderID = folderStore.folders.first?.id
                }
            }
            .sheet(isPresented: $showSearchView) {
                LocationSearchView { coord in
                    selectedCoordinate = coord
                    reverseGeocode(coord) { address in
                        readableAddress = address
                    }
                    showSearchView = false
                }
            }
            .sheet(isPresented: $showFolderPicker) {
                FolderPickerView { id in
                    selectedFolderID = id
                    showFolderPicker = false //有点问题
                }
            }
        }
    }

    func save() {
        guard let coord = selectedCoordinate,
              let folderID = selectedFolderID else { return }

        let newSpot = MemorySpot(title: title, description: note, coordinate: coord)

        for i in 0..<folderStore.folders.count {
            if folderStore.folders[i].id == folderID {
                folderStore.folders[i].spots.append(newSpot)
                folderStore.save()
                folderStore.focusCoordinate = CoordinateWrapper(coordinate: coord)
                break
            }
        }
    }

    func requestCurrentLocation() {
        let manager = CLLocationManager()
        manager.requestWhenInUseAuthorization()
        if let location = manager.location {
            let coord = location.coordinate
                    selectedCoordinate = coord
                    reverseGeocode(coord) { address in
                        readableAddress = address
                    }
        }
    }
}


#Preview {
//    AddMemoryView()
}
