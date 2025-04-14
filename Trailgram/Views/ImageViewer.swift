import SwiftUI
import Photos


struct FullImageViewer: View {
    let imagePaths: [String]
    @State var currentIndex: Int
    @Environment(\.dismiss) var dismiss
    @State private var showSaveAlert = false

    func saveImageToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized || status == .limited {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                print("✅ Image saved to Photos.")
                showSaveAlert = true
            } else {
                print("❌ Photo Library access denied.")
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let image = UIImage(contentsOfFile: imagePaths[currentIndex]) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        if let image = UIImage(contentsOfFile: imagePaths[currentIndex]) {
                            saveImageToPhotoLibrary(image)
                        }
                    }) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .alert("Saved to Photos", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        }
        .onTapGesture {
            dismiss()
        }
        
        
    }
}


struct ZoomableImageView: View {
    let imagePath: String
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            if let uiImage = UIImage(contentsOfFile: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                            }
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.black)
            } else {
                Text("Failed to load image")
                    .foregroundColor(.white)
            }
        }
    }
}
