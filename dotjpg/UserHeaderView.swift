//
//  UserHeaderView.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/3/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import Foundation
import UIKit

class UserHeaderView: UIView {
    let imageView: UIImageView
    let defaultHeight: CGFloat
    var inView = UIScrollView()
    var nav: UINavigationController!
    var fullImage: ViewImageVC!
    
    init(image: UIImage, height: CGFloat!, inView: UIScrollView!, nav: UINavigationController!) {
        let appFrame: CGRect = UIScreen.mainScreen().applicationFrame
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.fullImage = storyboard.instantiateViewControllerWithIdentifier("ViewImageVC") as! ViewImageVC
        self.fullImage.image = image
        
        imageView = UIImageView(frame: CGRectMake(0.0, 0.0, appFrame.width, height))
        defaultHeight = height
        self.inView = inView
        super.init(frame: imageView.frame)
        self.frame.origin.y = -defaultHeight - 20
        self.nav = nav
        self.imageView.image = image
        var view = UIView(frame: CGRect(x: appFrame.width/3.5, y: 0, width: 0, height: 200))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        imageView.clipsToBounds = true
        imageView.addSubview(view)
        
        self.addSubview(imageView)
        
        var backBtn = UIButton(frame: CGRectMake(5, 15, 60, 40))
        backBtn.setTitle("❮ yza", forState: .Normal)
        backBtn.titleLabel?.font = UIFont(name: "Hevletica", size: 14.0)
        backBtn.addTarget(self, action: Selector("back:"), forControlEvents: .TouchUpInside)
        self.addSubview(backBtn)
        inView.addSubview(self)
        inView.contentInset = UIEdgeInsetsMake(defaultHeight, 0.0, 0.0, 0.0)
        inView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
        var tapToView = UITapGestureRecognizer(target: self, action: Selector("viewImage"))
        self.addGestureRecognizer(tapToView)
    }
    
    func viewImage() {
        
        self.nav?.radialPushViewController(fullImage,startFrame: imageView.frame,duration:0.3,transitionCompletion: { () -> Void in
            
            
            
        })
    }
    
    func back(sender:UIButton) {
        nav!.radialPopViewController(duration: 0.3, startFrame: sender.frame, transitionCompletion: nil)
    }
    
    deinit {
        self.inView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            let offset: CGPoint! = change[NSKeyValueChangeNewKey]?.CGPointValue()
            self.frame.origin.y = offset.y
            self.frame.size.height = offset.y * -1
        }
    }
}