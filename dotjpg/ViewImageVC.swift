//
//  ViewImageVC.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/11/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import UIKit

class ViewImageVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    var imgURL: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if image != nil {
            imageView.image = image
        }else{
            imageView.setImageWithURL(imgURL, usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.enableRadialSwipe()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBar.hidden = true
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
}