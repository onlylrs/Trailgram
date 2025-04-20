//
//  ImageShareView.swift
//  Trailgram
//
//  Created by 刘闰生 on 4/20/25.
//

import SwiftUI
import UIKit


//class ShareHelper {
//    static func share(image: UIImage) {
//        guard let root = UIApplication.shared.connectedScenes
//                .compactMap({ $0 as? UIWindowScene })
//                .flatMap({ $0.windows })
//                .first(where: { $0.isKeyWindow })?.rootViewController else {
//            print("❌ No rootViewController found")
//            return
//        }
//
//        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
//        root.present(activityVC, animated: true)
//    }
//}
class ShareHelper {
    
    /// 分享单张图片
    static func share(image: UIImage) {
        share(items: [image])
    }

    /// 分享多张图片
    static func share(image: [UIImage]) {
        share(items: image)
    }

    /// 分享任意内容（图像、文本、URL）
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

struct ImageShareView: UIViewControllerRepresentable {
    let image: UIImage

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let items: [Any] = [image] // 可以加字符串、URL 等
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
//    ImageShareView()
}
