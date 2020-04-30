//
//  ViewController.swift
//  ClipperImg
//
//  Created by 罗石清 on 2020/4/30.
//  Copyright © 2020 HunanChangxingTrafficWisdom. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var showImgView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.navigationItem.title = "首页"
    }

    @IBAction func clipperAct(_ sender: Any) {
        let img = UIImage(named: "2.jpeg")
        //let img = UIImage(named: "1")
        let clipper = LsqImageClipperController(image: img!) { [weak self](clippImg) in
            self?.showImgView.image = clippImg
        }
        self.navigationController?.pushViewController(clipper, animated: true)
    }
    
}

