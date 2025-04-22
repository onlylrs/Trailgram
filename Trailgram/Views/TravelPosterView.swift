import SwiftUI

/// TravelPosterView allows users to generate travel posters from selected folders using different templates.
/// Integrates HTML-to-image API and supports sharing/exporting generated posters.
struct TravelPosterView: View {
    @Environment(FolderStore.self) var folderStore
    @State private var viewModel = TravelPosterViewModel()
    @State private var showShareSheet = false
    @State private var imageToShare: UIImage? = nil

    var body: some View {
        NavigationStack {
            VStack {
                // Folder Picker
                Button("Select Folder") {
                    showFolderPicker = true
                }
                if let selectedID = viewModel.selectedFolderID,
                   let selectedFolder = folderStore.allFoldersFlat.first(where: { $0.id == selectedID }) {
                    Text("Selected Folder: \(selectedFolder.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }

                // Template Picker
                Picker("Template", selection: $viewModel.selectedTemplate) {
                    ForEach(PosterTemplate.allCases) { template in
                        Text(template.rawValue.capitalized).tag(template)
                    }
                }
                .pickerStyle(.menu)
                .padding()

                // Generate button
                Button("Generate") {
                    Task {
                        if let folderID = viewModel.selectedFolderID,
                           let folder = folderStore.allFoldersFlat.first(where: { $0.id == folderID }) {
                            await viewModel.generatePosters(for: folder)
                        }
                    }
                }
                .disabled(viewModel.selectedFolderID == nil)

                // Images Grid
                if viewModel.isGenerating {
                    ProgressView("Generating...")
                } else if !viewModel.generatedImages.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 200))]) {
                            ForEach(viewModel.generatedImages.indices, id: \.self) { index in
                                let image = viewModel.generatedImages[index]
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(0)
                                    .onTapGesture {
                                        selectedImageIndex = index
                                        showFullImage = true
                                    }
                            }
                        }
                        .padding()
                    }
                    if !viewModel.generatedImages.isEmpty {
                        Button("Share Poster") {
                            if !viewModel.generatedImages.isEmpty {
                                ShareHelper.share(image: viewModel.generatedImages)
                            }

                        }
                        .padding(.bottom)
                    }
                }

                // Clear button
//                Button("Clear", role: .destructive) {
//                    viewModel.clear()
//                }
//                .padding(.top)
            }
            .navigationTitle("Travel Posters")

            .sheet(isPresented: $showFolderPicker) {
                MoveToFolderView(onSelect: { id in
                    viewModel.selectedFolderID = id
                    showFolderPicker = false
                }, confirmButtonText: "Select")
            }
            .fullScreenCover(isPresented: $showFullImage) {
                FullImageViewer(
                    imagePaths: viewModel.tempImagePaths,
                    currentIndex: selectedImageIndex ?? 0  // default to 0 if nil
                )
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    @State private var showFolderPicker = false
    @State private var showFullImage = false
    @State private var selectedImageIndex: Int? = nil
}

extension UIImage {
    func saveToTemp() -> String {
        let filename = UUID().uuidString + ".jpg"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try self.jpegData(compressionQuality: 0.8)?.write(to: url)
            print("Image saved to temp: \(url.path)")
            return url.path
        } catch {
            print("Failed to save image: \(error.localizedDescription)")
            return ""
        }
    }
}
