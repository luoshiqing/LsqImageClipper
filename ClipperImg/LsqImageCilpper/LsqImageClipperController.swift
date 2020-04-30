//
//  LsqImageCilpperController.swift
//  ClipperImg
//
//  Created by 罗石清 on 2020/4/30.
//  Copyright © 2020 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

class LsqImageClipperController: UIViewController {

    private var clippImage: UIImage!
    private var clippedHandler: ((UIImage)->Swift.Void)?
    init(image: UIImage, clippedHandler: ((UIImage)->Swift.Void)?) {
        super.init(nibName: nil, bundle: nil)
        
        self.clippImage = image
        self.clippedHandler = clippedHandler
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var clipperView: LsqClipperImgView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "裁剪图片"
        self.setNavItems()
        self.loadSomeView()
    }
    
    private func setNavItems() {
        let left = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(self.navItemAct(_:)))
        left.tag = -1
        self.navigationItem.leftBarButtonItem = left
        
        let right = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(self.navItemAct(_:)))
        right.tag = 1
        self.navigationItem.rightBarButtonItem = right
    }
    
    @objc private func navItemAct(_ send: UIBarButtonItem) {
        let tag = send.tag
        if tag == -1 {
            self.navigationController?.popViewController(animated: true)
        } else {
            guard let clippedImg = self.clipperView?.getClipImage() else {
                print("获取图片失败")
                self.navigationController?.popViewController(animated: true)
                return
            }
            self.clippedHandler?(clippedImg)
            self.navigationController?.popViewController(animated: true)
        }
    }
  
    private func loadSomeView() {
        let navH = self.navigationController?.navigationBar.frame.height ?? 0
        let statusH = UIApplication.shared.statusBarFrame.height
        let nsH = navH + statusH
        
        let isTranslucent = self.navigationController?.navigationBar.isTranslucent ?? true
        var y: CGFloat = 0
        let h: CGFloat = UIScreen.main.bounds.height - nsH
        if isTranslucent {
            y = nsH
        }
        
        let rect = CGRect(x: 0, y: y, width: self.view.frame.width, height: h)
        let w = self.view.frame.width
        let resultImgSize = CGSize(width: w, height: w)
        clipperView = LsqClipperImgView(frame: rect, image: self.clippImage, resultImgSize: resultImgSize)
        self.view.addSubview(clipperView!)
    }
}

