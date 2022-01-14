//
//  ZLPhotoModel.swift
//  ZLPhotoBrowser
//
//  Created by long on 2020/8/11.
//
//  Copyright (c) 2020 Long Zhang <495181165@qq.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Photos

extension ZLPhotoModel {
    
    public enum MediaType: Int {
        case unknown = 0
        case image
        case gif
        case livePhoto
        case video
    }
    
}


public class ZLPhotoModel: NSObject {
    //[ZLModify]
    public var ident: String
    
    public let asset: PHAsset
    
    public var type: ZLPhotoModel.MediaType = .unknown
    
    public var duration: String = ""
    
    public var isSelected: Bool = false
    //[ZLModify] 修改 editImage 的访问
//    private var pri_editImage: UIImage? = nil
//    public var editImage: UIImage? {
//        set {
//            pri_editImage = newValue
//        }
//        get {
//            if let _ = self.editImageModel {
//                return pri_editImage
//            } else {
//                return nil
//            }
//        }
//    }
    public var editImage: UIImage?
    
    public var second: Second {
        guard type == .video else {
            return 0
        }
        return Int(round(asset.duration))
    }
    
    public var whRatio: CGFloat {
        return CGFloat(self.asset.pixelWidth) / CGFloat(self.asset.pixelHeight)
    }
    
    public var previewSize: CGSize {
        let scale: CGFloat = 2 //UIScreen.main.scale
        if self.whRatio > 1 {
            let h = min(UIScreen.main.bounds.height, ZLMaxImageWidth) * scale
            let w = h * self.whRatio
            return CGSize(width: w, height: h)
        } else {
            let w = min(UIScreen.main.bounds.width, ZLMaxImageWidth) * scale
            let h = w / self.whRatio
            return CGSize(width: w, height: h)
        }
    }
    
    // Content of the last edit.
    public var editImageModel: ZLEditImageModel?
    
    public init(asset: PHAsset) {
        self.ident = asset.localIdentifier
        self.asset = asset
        super.init()
        
        self.type = self.transformAssetType(for: asset)
        if self.type == .video {
            self.duration = self.transformDuration(for: asset)
        }
    }
    
    public func transformAssetType(for asset: PHAsset) -> ZLPhotoModel.MediaType {
        switch asset.mediaType {
        case .video:
            return .video
        case .image:
            if (asset.value(forKey: "filename") as? String)?.hasSuffix("GIF") == true {
                return .gif
            }
            if #available(iOS 9.1, *) {
                if asset.mediaSubtypes.contains(.photoLive) {
                    return .livePhoto
                }
            }
            return .image
        default:
            return .unknown
        }
    }
    
    public func transformDuration(for asset: PHAsset) -> String {
        let dur = Int(round(asset.duration))
        
        switch dur {
        case 0..<60:
            return String(format: "00:%02d", dur)
        case 60..<3600:
            let m = dur / 60
            let s = dur % 60
            return String(format: "%02d:%02d", m, s)
        case 3600...:
            let h = dur / 3600
            let m = (dur % 3600) / 60
            let s = dur % 60
            return String(format: "%02d:%02d:%02d", h, m, s)
        default:
            return ""
        }
    }
    
}


public func ==(lhs: ZLPhotoModel, rhs: ZLPhotoModel) -> Bool {
    return lhs.ident == rhs.ident
}

// zlmodify
extension ZLPhotoModel {
    private struct AssociateKey {
        // 图片URL
        static var photoURLStrKey = 0
        // 视频URL
        static var videoURLStrKey = 1
        // 图片高宽比
        static var photoHWScaleKey = 2
        // 视频是否gif封面
        static var videoIsHasGifCoverKey = 3
        // 视频自定义封面Image
        static var videoCoverImageKey = 4
        // 是否需要3:4展示
        static var isThreeToFourDisplayKey = 5
        // 本地视频URL
        static var localVideoURLStrKey = 6
        // 本地缓存的原图
        static var originalImageKey = 7
    }
    
    var originalImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociateKey.originalImageKey) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.originalImageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var isThreeToFourDisplay: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociateKey.isThreeToFourDisplayKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.isThreeToFourDisplayKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var videoCoverImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &AssociateKey.videoCoverImageKey) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.videoCoverImageKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var videoIsHasGifCover: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociateKey.videoIsHasGifCoverKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.videoIsHasGifCoverKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var photoHWScale: String? {
        get {
            return objc_getAssociatedObject(self, &AssociateKey.photoHWScaleKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.photoHWScaleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var photoURLStr: String? {
        get {
            return objc_getAssociatedObject(self, &AssociateKey.photoURLStrKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.photoURLStrKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var videoURLStr: String? {
        get {
            return objc_getAssociatedObject(self, &AssociateKey.videoURLStrKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.videoURLStrKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var localVideoURLStr: String? {
        get {
            return objc_getAssociatedObject(self, &AssociateKey.localVideoURLStrKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociateKey.localVideoURLStrKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var isOnLine: Bool {
        return photoURLStr != nil
    }
}
