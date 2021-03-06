//
//  ViewImageVC.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/11/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import UIKit

class ViewImageVC: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var image: UIImage?
    var imgURL: NSURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = UIImageView(image: UIImage(named: "black.png"))
        if image != nil {
            imageView = UIImageView(image: image)
        }
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.contentSize = imageView.bounds.size
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollEnabled = false
        scrollView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        scrollView.contentOffset = CGPoint(x: 1000, y: 450)
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        imageView.tag = 101
        scrollView.tag = 102
        scrollView.delegate = self
        if image != nil {
            setZoomScale()
            setupGestureRecognizer()
        }
        if image == nil {
            imageView.setImageWithURL(imgURL, placeholderImage:  UIImage(named: "black.png"), completed: {(_)in
                self.view.viewWithTag(101)?.removeFromSuperview()
                self.view.viewWithTag(102)?.removeFromSuperview()
                self.imageView = UIImageView(image: self.imageView.image)
                self.scrollView.contentSize = self.imageView.bounds.size
                self.scrollView.addSubview(self.imageView)
                self.view.addSubview(self.scrollView)
                self.setZoomScale()
                self.setupGestureRecognizer()
                self.scrollView.layoutSubviews()
                
                }, usingActivityIndicatorStyle: .White)
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let imageViewSize = imageView.frame.size
            let scrollViewSize = scrollView.bounds.size
            
            let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
            let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
            
            scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        }
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 0.0
    }
    
    func setupGestureRecognizer() {
        let doubleTap = UITapGestureRecognizer(target: self, action: "handleDoubleTap:")
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }

}