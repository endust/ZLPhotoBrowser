//
//  UIImageView+ZLPhotoBrowser.swift
//  ZLPhotoBrowser
//
//  Created by Winn on 2022/1/14.
//

import Foundation
import UIKit
import Kingfisher
// zlmodify
extension UIImageView {
    func zlphoto_setImage(with url: URL?, placeholder: UIImage? = getImage("zl_pic_loading")) {
        if let placeholder = placeholder {
            // backgroundColor = UIColor(hex: "EAEAEA") // EA = 234
            image = placeholder
        }
        var finalUrl = url
        defer {
            kf.setImage(with: finalUrl, placeholder: placeholder, options: [.downloadPriority(0.5)])
        }
        
        guard let url = url, let host = url.host?.lowercased(), host.hasSuffix(".dxycdn.com") else {
            return
        }
        
        // 原始 URL 已经包含感叹号，不再处理
        guard url.absoluteString.components(separatedBy: "!w").count == 1 else {
            return
        }
        let width = Int(bounds.width * UIScreen.main.scale)
        guard width > 0 else {
            return
        }
        // 找到合适的尺寸
        guard let matchedWidth = ZLPhotoScaleAbleSize.suitable(for: width)?.rawValue else {
            return
        }
        
        let str = url.absoluteString + "!w\(matchedWidth)"
        
        finalUrl = URL(string: str) ?? url
    }
}

// zlmodify
enum ZLPhotoScaleAbleSize: Int, RawRepresentable {
    typealias RawValue = Int
    case maximum = 900
    case seven = 720
    case six = 640
    case three = 330
    case two = 299
    case one = 160
    case minimum = 64
    
    static func suitable(for width: Int) -> ZLPhotoScaleAbleSize? {
        switch width {
        case ZLPhotoScaleAbleSize.seven.rawValue ... ZLPhotoScaleAbleSize.maximum.rawValue :
            return ZLPhotoScaleAbleSize.maximum
        case ZLPhotoScaleAbleSize.six.rawValue ... ZLPhotoScaleAbleSize.seven.rawValue:
            return ZLPhotoScaleAbleSize.seven
        case ZLPhotoScaleAbleSize.three.rawValue ... ZLPhotoScaleAbleSize.six.rawValue:
            return ZLPhotoScaleAbleSize.six
        case ZLPhotoScaleAbleSize.two.rawValue ... ZLPhotoScaleAbleSize.three.rawValue:
            return ZLPhotoScaleAbleSize.three
        case ZLPhotoScaleAbleSize.one.rawValue ... ZLPhotoScaleAbleSize.two.rawValue:
            return ZLPhotoScaleAbleSize.two
        case ZLPhotoScaleAbleSize.minimum.rawValue ... ZLPhotoScaleAbleSize.one.rawValue:
            return ZLPhotoScaleAbleSize.one
        case 0 ... ZLPhotoScaleAbleSize.minimum.rawValue:
            return ZLPhotoScaleAbleSize.minimum
        default:
            return nil
        }
    }
}
