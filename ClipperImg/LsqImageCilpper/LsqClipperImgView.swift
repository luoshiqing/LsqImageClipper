//
//  LsqClipperImgView.swift
//  ClipperImg
//
//  Created by 罗石清 on 2020/4/30.
//  Copyright © 2020 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

class LsqClipperImgView: UIView {

    private var clipImage: UIImage!
    private var resultImgSize: CGSize = .zero
    
    private lazy var baseImgView: UIImageView = {
        let baseImgView = UIImageView()
        self.addSubview(baseImgView)
        self.sendSubviewToBack(baseImgView)
        return baseImgView
    }()
    private var clipperView = UIImageView()
    
    private let minWidth:CGFloat = 60
    private var panTouch:CGPoint = CGPoint.zero
    private var scaleDistance:CGFloat = 0 //缩放距离
    
    init(frame: CGRect, image: UIImage, resultImgSize: CGSize) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        self.clipImage = image
        self.resultImgSize = resultImgSize
        self.loadSomeView()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var fillLayer: CAShapeLayer? = {
        let fillLayer = CAShapeLayer()
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.5
        self.layer.addSublayer(fillLayer)
        return fillLayer
    }()
    
    private func loadSomeView() {
        self.layer.contentsGravity = .resizeAspect
        self.setClipperView()
        self.setBaseImgView()
    }
    //TODO:获取裁剪图片
    public func getClipImage() -> UIImage? {
        guard let baseSize = self.baseImgView.image?.size else { return nil }
        let scale = UIScreen.main.scale * baseSize.width / self.baseImgView.frame.width
        let rect = self.convert(self.clipperView.frame, to: self.baseImgView)
        let rect2 = CGRect(x: rect.origin.x * scale, y: rect.origin.y * scale, width: rect.width * scale, height: rect.height * scale)
        
        guard let cgImg = self.baseImgView.image?.cgImage?.cropping(to: rect2) else { return nil }
        
        let clippedImg = UIImage(cgImage: cgImg)
        return clippedImg
    }
    
    //裁剪区域
    private func setClipperView() {
        
        let kscWidth = UIScreen.width
        let kscHeight = UIScreen.height - self.navHeight
        
        var width = kscWidth
        var height = kscHeight
        
        let endW = self.resultImgSize.height / height * width
        if self.resultImgSize.width > endW {
            height = kscWidth / self.resultImgSize.width * self.resultImgSize.height
        } else {
            width = kscHeight / self.resultImgSize.height * self.resultImgSize.width
        }
        let y = (kscHeight - height) / 2
        let x = (kscWidth - width) / 2
        
        clipperView.frame = CGRect(x: x, y: y, width: width, height: height)
        clipperView.layer.borderColor = UIColor.white.cgColor
        clipperView.layer.borderWidth = 2
        self.addSubview(clipperView)
        
        self.correctFillLayer()
    }
    
    private func correctFillLayer() {
        let path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 0)
        let circlePath = UIBezierPath(roundedRect: self.clipperView.frame, cornerRadius: 0)
        path.append(circlePath)
        path.usesEvenOddFillRule = true
        self.fillLayer?.path = path.cgPath
    }
    //图片
    private func setBaseImgView() {
        
        let maxW = self.frame.width
        
        var imgW = self.clipImage.size.width
        var imgH = self.clipImage.size.height
        if imgW != maxW {
            imgW = maxW
        }
        imgH = imgH / imgW * maxW
        
        if imgH < self.clipperView.frame.height {
            imgH = self.clipperView.frame.height
        }
        imgW = self.clipImage.size.width / self.clipImage.size.height * imgH
        
        let img = self.clipImage.scaledToSize(newSize: CGSize(width: imgW, height: imgH), withScale: false)
        
        self.baseImgView.image = img
        self.baseImgView.frame = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        
        self.correctBackImgView()
    }
    
    private func correctBackImgView(){
        var x = self.baseImgView.frame.origin.x
        var y = self.baseImgView.frame.origin.y
        
        var height = self.baseImgView.frame.height
        var width = self.baseImgView.frame.width
        
        let clippSize = self.clipperView.frame.size
        
        if width < clippSize.width {
            width = clippSize.width
            height = width / self.baseImgView.frame.width * height
        }
        if height < clippSize.height {
            height = clippSize.height
            width = height / self.baseImgView.frame.height * width
        }
        
        let point = self.clipperView.frame.origin
        
        let maxX = point.x + self.clipperView.frame.width - width
        
        if x > point.x {
            x = point.x
        } else if x < maxX {
            x = maxX
        }
        let maxY = point.y + self.clipperView.frame.height - height
        if y > point.y {
            y = point.y
        } else if y < maxY {
            y = maxY
        }
        
        self.baseImgView.frame = CGRect(x: x, y: y, width: width, height: height)
    }
}


extension LsqClipperImgView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let allTouches = event?.allTouches {
            let touchCount = allTouches.count
            if touchCount == 1, let point = allTouches.first?.location(in: self) {
                self.panTouch = point
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.willChangeValue(forKey: "corp")
        guard let allTouches = event?.allTouches else { return }
        let touchCount = allTouches.count
        
        switch touchCount {
        case 1:
            guard let touchCurrent = allTouches.first?.location(in: self) else { return }
            let x = touchCurrent.x - self.panTouch.x
            let y = touchCurrent.y - self.panTouch.y
            let clippCenter = self.clipperView.center
            self.clipperView.center = CGPoint(x: clippCenter.x + x, y: clippCenter.y + y)
            self.panTouch = touchCurrent
        case 2:
            self.scaleView(self.clipperView, touches: allTouches)
        default:
            break
        }
        self.correctFillLayer()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.correctClipperView()
    }
    
    private func scaleView(_ view: UIView, touches: Set<UITouch>){
        
        var tempTouchs = [UITouch]()
        for touch in touches {
            tempTouchs.append(touch)
        }
        
        let touch1 = tempTouchs[0].location(in: self)
        let touch2 = tempTouchs[1].location(in: self)
        let distance = self.distanceBetweenTwoPoints(touch1, toPoint: touch2)
        
        if self.scaleDistance > 0 {
            var imgFrame = view.frame
            if distance > self.scaleDistance + 2 {
                imgFrame.size.width += 10
                self.scaleDistance = distance
            }
            if distance < scaleDistance - 2 {
                imgFrame.size.width -= 10
                self.scaleDistance = distance
            }
            let viewSize = view.frame.size
            imgFrame.size.height = viewSize.height * imgFrame.width / viewSize.width
            let mainWidth = UIScreen.width
            let imgWidth = imgFrame.width > mainWidth ? mainWidth : imgFrame.width
            let resultWidth = resultImgSize.width == 0 ? 1 : resultImgSize.width
            let imgHeight = imgWidth * self.resultImgSize.height / resultWidth
            
            let addwidth = imgWidth - viewSize.width
            let addheight = imgHeight - viewSize.height
            
            if (imgHeight != 0) && (imgWidth != 0) {
                let x = imgFrame.origin.x - addwidth / 2
                let y = imgFrame.origin.y - addheight / 2
                view.frame = CGRect(x: x, y: y, width: imgWidth, height: imgHeight)
            }
            
        } else {
            self.scaleDistance = distance
        }
        
        
    }
    
    private func distanceBetweenTwoPoints(_ fromPoint: CGPoint, toPoint:CGPoint) -> CGFloat {
        let x = toPoint.x - fromPoint.x
        let y = toPoint.y - fromPoint.y
        return CGFloat(sqrtf(Float(x * x + y * y)))
    }
    
    private func correctClipperView(){
        var width = self.clipperView.frame.width
        var height: CGFloat = 0
        
        if width < self.minWidth {
            width = self.minWidth
        }
        if width > UIScreen.width {
            width = UIScreen.width
        }
        height = width / self.resultImgSize.width * self.resultImgSize.height
        let clipPoint = self.clipperView.frame.origin
        var x = clipPoint.x
        var y = clipPoint.y
        let baseImgPoint = self.baseImgView.frame.origin
        if x < baseImgPoint.x {
            x = baseImgPoint.x
        }
        if x > (UIScreen.width - width) {
            x = UIScreen.width - width
        }
        if y < baseImgPoint.y {
            y = baseImgPoint.y
        }
        let baseRect = self.baseImgView.frame
        let clipperRect = self.clipperView.frame
        let tempy = baseImgPoint.y + baseRect.height - clipperRect.height
        if y > tempy {
            y = tempy
        }
        self.clipperView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        self.correctFillLayer()
    }
    
}


