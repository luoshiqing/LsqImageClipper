//
//  LsqExtension.swift
//  ClipperImg
//
//  Created by 罗石清 on 2020/4/30.
//  Copyright © 2020 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

extension UIScreen {
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.height
    static let statusHeigh = UIApplication.shared.statusBarFrame.height
}

extension UIDevice {
    //是否是iPhone X
    class func isXPhone() -> Bool {
        if #available(iOS 11.0, *) {
            guard let window = UIApplication.shared.delegate?.window, let unwrapedWindow = window else {
                return false
            }
            if unwrapedWindow.safeAreaInsets.left > 0 || unwrapedWindow.safeAreaInsets.bottom > 0 {
                return true
            }
        }
        return false
    }
}

extension UIView {
    
    var navHeight: CGFloat {
        if UIDevice.isXPhone() {
            return 88
        } else {
            return 64
        }
    }
    
}

extension UIImage{
    func scaledToSize(newSize:CGSize,withScale:Bool) -> UIImage {
        var scale:CGFloat = 1
        if withScale {
            scale = UIScreen.main.scale
        }
        let mynewSize = CGSize(width: newSize.width * scale, height: newSize.height * scale)
        UIGraphicsBeginImageContextWithOptions(mynewSize, false, 0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: mynewSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
}
