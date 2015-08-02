//
//  ViewController.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 7/31/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import UIKit
import ImageIO

class MainVC: UIViewController {

    var api: APIController!
    var images: [Images]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.api = APIController()
        self.api.delegate = self
        self.api.clientRequest(["controller":"image", "action":"getAllSpecial", "page":0], objectForKey: "data")
        var imageView = UIImageView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        self.view.addSubview(imageView)
//        imageView.sd_setImageWithURL(NSURL(string: "http://dotjpg.co/83Zml2.png"), placeholderImage: nil, options: .CacheMemoryOnly, progress: {
//            (receivedSize, expectedSize) -> Void in
//       
//            println(receivedSize)
//        }, completed: nil)
        
        imageView.setImageWithURL(NSURL(string: "http://dotjpg.co/83Zml2.png"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MainVC: APIProtocol {
    func success(success: Bool, resultsArr:NSArray?, results:NSDictionary?) {
        if success {
            self.images = Images.ImagesWithJSON(resultsArr!)
        }
    }
}

