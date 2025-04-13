//
//  ImageGridView.swift
//  Trailgram
//
//  Created by 刘闰生 on 12/4/2025.
//

import SwiftUI

struct ImageGridView: View {
    var imagePaths: [String]
    var onDelete: (String) -> Void
    var onTap: (Int) -> Void
    var onAdd: () -> Void

    let columns = [GridItem(.adaptive(minimum: 80))]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(Array(imagePaths.enumerated()), id: \.1) { index, path in
                ZStack(alignment: .topTrailing) {
                    if let uiImage = UIImage(contentsOfFile: path) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                            .onTapGesture {
                                onTap(index)
                            }
                            .contextMenu {
                                Button("Delete", role: .destructive) {
                                    onDelete(path)
                                }
                            }
                    }
                }
            }

            // Add Button
            Button(action: onAdd) {
                VStack {
                    Image(systemName: "plus")
                        .font(.title)
                    Text("Add")
                        .font(.caption)
                }
                .frame(width: 80, height: 80)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

//#Preview {
//    ImageGridView()
//}
