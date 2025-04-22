//
//  AddMemoryView.swift
//  Trailgram
//
//  Created by 刘闰生 on 8/4/2025.
//

import SwiftUI
import CoreLocation
import PhotosUI

/// AddMemoryView allows users to create a new memory spot with title, notes, location, folder, and optional image.
/// It supports selecting current location or searching by place, picking from Photos, or adding manually.
struct AddMemoryView: View {
    @Environment(FolderStore.self) var folderStore
    @Environment(\.dismiss) var dismiss
    @State private var viewModel = AddMemoryViewModel()

    @State private var showSearchView = false
    @State private var showFolderPicker = false
    @State private var showFullImageViewer = false

    init(prefillCoordinate: CLLocationCoordinate2D? = nil) {
        _viewModel = State(initialValue: AddMemoryViewModel(prefillCoordinate: prefillCoordinate))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("New Spot")
                    .font(.title2)
                    .bold()
                Spacer()
                Button("Save") {
                    viewModel.save()
                }
                .disabled(viewModel.title.isEmpty || viewModel.selectedCoordinate == nil || viewModel.selectedFolderID == nil)
            }
            .padding()

            Form {
                Section(header: Text("Title")) {
                    TextField("Enter a title", text: $viewModel.title)
                }

                Section(header: Text("Note")) {
                    TextEditor(text: $viewModel.note)
                        .frame(height: 100)
                }

                Section(header: Text("Image")) {
                    VStack(alignment: .leading, spacing: 10) {
                        if let filename = viewModel.imagePath {
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
                                    viewModel.imagePath = nil
                                } label: {
                                    Label("Remove Picture", systemImage: "trash")
                                }
                            } else {
                                Text("❌ Image not found")
                            }
                        } else {


                            PhotosPicker(selection: $viewModel.selectedImageItem, matching: .images) {
                                Label("Add Picture", systemImage: "plus")
                                    .foregroundColor(.blue)
                            }
                            .onChange(of: viewModel.selectedImageItem) { newItem in
                                viewModel.selectedImageItem = newItem
                                Task {
                                    await viewModel.processSelectedImageItem()
                                }
                            }
                        }
                    }
                    .padding(.vertical, 5)
                }

                Section(header: Text("Location")) {
                    Button("Use Current Location") {
                        viewModel.requestCurrentLocation()
                    }

                    Button("Search Location") {
                        showSearchView = true
                    }

                    if viewModel.selectedCoordinate != nil {
                        Label(viewModel.readableAddress, systemImage: "mappin.and.ellipse")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Choose Folder")) {
                    Button {
                        showFolderPicker = true
                    } label: {
                        Text(folderStore.name(for: viewModel.selectedFolderID) ?? "Select Folder")
                            .foregroundStyle(.orange)
                    }
                }
            }
            .onAppear {
                viewModel.folderStore = folderStore
                viewModel.dismissAction = { dismiss() }
                if viewModel.selectedFolderID == nil {
                    viewModel.selectedFolderID = folderStore.folders.first?.id
                }
                viewModel.reverseGeocodeIfNeeded()
            }
            .sheet(isPresented: $showSearchView) {
                LocationSearchView { coord in
                    viewModel.selectedCoordinate = coord
                    viewModel.reverseGeocodeIfNeeded()
                    showSearchView = false
                }
            }
            .sheet(isPresented: $showFolderPicker) {
                MoveToFolderView(
                    onSelect: { id in
                        viewModel.selectedFolderID = id
                        showFolderPicker = false
                    },
                    confirmButtonText: "Put Here"
                )
            }

            .fullScreenCover(isPresented: $showFullImageViewer) {
                if let filename = viewModel.imagePath {
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
}



#Preview {
//    AddMemoryView()
}
