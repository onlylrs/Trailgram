//
//  ImageShareView.swift
//  Trailgram
//
//  Created by 刘闰生 on 4/20/25.
//

import SwiftUI
import UIKit

/// ImageShareView wraps a UIKit UIActivityViewController to allow image sharing in SwiftUI.
/// Includes ShareHelper for use outside of views (e.g., ViewModel or Manager).
struct ImageShareView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let items: [Any] = [image] // 可以加字符串、URL 等
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}


class ShareHelper {
    
    /// share one image
    static func share(image: UIImage) {
        share(items: [image])
    }

    /// share multiple images
    static func share(image: [UIImage]) {
        share(items: image)
    }

    /// share any contents (text, urls, ...)
    static func share(items: [Any]) {
        guard let root = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?.rootViewController else {
                print("❌ No rootViewController found")
                return
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = root.view // iPad support

        root.present(activityVC, animated: true)
    }
}
