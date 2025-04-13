import SwiftUI

struct FullImageViewer: View {
    let imagePaths: [String]
    let startIndex: Int

    @Environment(\.dismiss) var dismiss
    @State private var currentIndex: Int = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(imagePaths.indices, id: \.self) { index in
                ZoomableImageView(imagePath: imagePaths[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .background(Color.black.ignoresSafeArea())
        .onAppear {
            currentIndex = startIndex
        }
        .overlay(
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                }
            }, alignment: .topTrailing
        )
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
