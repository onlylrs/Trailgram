//
//  AddMemoryView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI
import CoreLocation
import PhotosUI

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
    
    var shouldUsePrefill: Bool {
        prefillCoordinate != nil
    }
    
    @State private var selectedImageItem: PhotosPickerItem? = nil
    @State private var imagePath: String? = nil
    @State private var showFullImageViewer = false
    
    init(prefillCoordinate: CLLocationCoordinate2D? = nil) {
        self.prefillCoordinate = prefillCoordinate
        self._selectedCoordinate = State(initialValue: prefillCoordinate)
        self._readableAddress = State(initialValue: "")
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0){
            HStack {
                Text("New Spot")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("Save") {
                    save()
                    dismiss()
                }
                .disabled(title.isEmpty || selectedCoordinate == nil || selectedFolderID == nil)
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
                
                Section(header: Text("Image")) {
                    VStack(alignment: .leading, spacing: 10) {
                        if let filename = imagePath {
                            let url = FileManager.default
                                .urls(for: .documentDirectory, in: .userDomainMask)
                                .first!
                                .appendingPathComponent(filename)

                            if let uiImage = UIImage(contentsOfFile: url.path) {
                                Button(action: {
                                    showFullImageViewer = true
                                }) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .cornerRadius(12)
                                }
                                .buttonStyle(.plain)

                                Button(role: .destructive) {
                                    imagePath = nil
                                } label: {
                                    Label("Remove Picture", systemImage: "trash")
                                }
                            } else {
                                Text("❌ Image not found")
                            }
                        } else {
                            PhotosPicker(selection: $selectedImageItem, matching: .images) {
                                Label("Add Picture", systemImage: "plus")
                                    .foregroundColor(.blue)
                            }
                            .onChange(of: selectedImageItem) { newItem in
                                if let item = newItem {
                                    Task {
                                        do {
                                            if let data = try? await item.loadTransferable(type: Data.self),
                                               let uiImage = UIImage(data: data) {
                                                let filename = UUID().uuidString + ".jpg"
                                                let url = FileManager.default
                                                    .urls(for: .documentDirectory, in: .userDomainMask)
                                                    .first!
                                                    .appendingPathComponent(filename)
                                                if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
                                                    try? jpegData.write(to: url)
                                                    imagePath = filename
                                                    print("✅ Saved image to: \(url.path)")
                                                } else {
                                                    print("Failed to convert UIImage to JPEG")
                                                }
                                            } else {
                                                print("❌ Failed to load image data from PhotosPickerItem")
                                            }
                                        } catch {
                                            print("❌ Error loading or saving image: \(error.localizedDescription)")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }

                
                Section(header: Text("Location")) {
                    Button("Use Current Location") {
                        requestCurrentLocation()
                    }
                    
                    Button("Search Location") {
                        showSearchView = true
                    }
                    
                    if selectedCoordinate != nil {
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
            }
            .onAppear {
                if shouldUsePrefill, let coord = selectedCoordinate {
                    
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
                MoveToFolderView(
                    onSelect: { id in
                        selectedFolderID = id
                        showFolderPicker = false
                    },
                    confirmButtonText: "Put Here"
                )
            }
            .fullScreenCover(isPresented: $showFullImageViewer) {
                if let filename = imagePath {
                    let url = FileManager.default
                        .urls(for: .documentDirectory, in: .userDomainMask)
                        .first!
                        .appendingPathComponent(filename)

                    if let image = UIImage(contentsOfFile: url.path) {
                        ZStack {
                            Color.black.ignoresSafeArea()
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .onTapGesture {
                                    showFullImageViewer = false
                                }
                        }
                    }
                }
            }

        }
    }

    
    func save() {
        guard let coord = selectedCoordinate,
              let folderID = selectedFolderID else { return }

        let newSpot = MemorySpot(title: title, description: note, coordinate: coord, imagePath: imagePath)
    
//        for i in 0..<folderStore.folders.count {
//            if folderStore.folders[i].id == folderID {
//                folderStore.folders[i].spots.append(newSpot)
//                folderStore.save()
//                folderStore.focusCoordinate = CoordinateWrapper(coordinate: coord)
//                break
//            }
//        }
        folderStore.appendSpot(newSpot, to: folderID)  // ✅ 使用新方法
        folderStore.focusCoordinate = CoordinateWrapper(coordinate: coord)
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
