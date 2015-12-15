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
    var api: APIController!
    private (set)var imageName: String!
    
    init(image: UIImage?, height: CGFloat!, inView: UIScrollView!, nav: UINavigationController!, imgURL: NSURL) {
        let appFrame: CGRect = UIScreen.mainScreen().applicationFrame
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.fullImage = storyboard.instantiateViewControllerWithIdentifier("ViewImageVC") as! ViewImageVC
        if (image != nil) {
            self.fullImage.image = image
        }else{
            self.fullImage.imgURL = imgURL
        }
        self.imageName = "\(imgURL)"
        imageView = UIImageView(frame: CGRectMake(0.0, 0.0, appFrame.width, height))
        defaultHeight = height
        self.inView = inView
        super.init(frame: imageView.frame)
        self.frame.origin.y = -defaultHeight - 20
        self.nav = nav
        if (image != nil) {
            self.imageView.image = image
        }else{
            self.imageView.setImageWithURL(imgURL, usingActivityIndicatorStyle: .Gray)
        }
        let view = UIView(frame: CGRect(x: appFrame.width/3.5, y: 0, width: 0, height: 200))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        imageView.clipsToBounds = true
        imageView.addSubview(view)
        
        self.addSubview(imageView)
        
        let backBtn = UIButton(frame: CGRectMake(5, 15, 60, 40))
        backBtn.setTitle("❮ yza", forState: .Normal)
        backBtn.titleLabel?.font = UIFont(name: "Hevletica", size: 14.0)
        backBtn.addTarget(self, action: Selector("back:"), forControlEvents: .TouchUpInside)
        self.addSubview(backBtn)
        
        let report = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width - 60, 15, 60, 40))
        report.setImage(UIImage(named:"report"), forState: .Normal)
        report.addTarget(self, action: Selector("report:"), forControlEvents: .TouchUpInside)
        self.addSubview(report)
        
        inView.addSubview(self)
        inView.contentInset = UIEdgeInsetsMake(defaultHeight, 0.0, 0.0, 0.0)
        inView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
        let tapToView = UITapGestureRecognizer(target: self, action: Selector("viewImage"))
        self.addGestureRecognizer(tapToView)

    }
    
    func viewImage() {
        self.nav?.radialPushViewController(fullImage,startFrame: imageView.frame,duration:0.3,transitionCompletion: { () -> Void in
            
        })
    }
    
    func back(sender:UIButton) {
        nav!.radialPopViewController(0.3, startFrame: sender.frame, transitionCompletion: nil)
    }
    
    deinit {
        self.inView.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentOffset" {
            
            let offset: CGPoint! = change?[NSKeyValueChangeNewKey]?.CGPointValue
            self.frame.origin.y = offset.y
            self.frame.size.height = offset.y * -1
        }
    }
    
    func report(sender: AnyObject){
        guard let button = sender as? UIView else {
            return
        }
        
        let shareMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if let presentationController = shareMenu.popoverPresentationController {
            presentationController.sourceView = button
            presentationController.sourceRect = button.bounds
        }

        let report = UIAlertAction(title: "Report", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) -> Void in
            self.reportList(sender)
        })
        let cancelAction = UIAlertAction(title: "Beset", style: UIAlertActionStyle.Cancel, handler: nil)
        
        shareMenu.addAction(report)
        shareMenu.addAction(cancelAction)
        
        self.nav.presentViewController(shareMenu, animated: true, completion: nil)

    }
    
    func reportList(sender: AnyObject) {
        guard let button = sender as? UIView else {
            return
        }

        let shareMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        if let presentationController = shareMenu.popoverPresentationController {
            presentationController.sourceView = button
            presentationController.sourceRect = button.bounds
        }
        
        api = APIController()
        self.api.delegate = self
        
        let spam = UIAlertAction(title: "Spam", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) -> Void in
            self.api.SendReport(["report_type":"spam","image":self.imageName])
        })
        let insult = UIAlertAction(title: "Ahlaksyz surat", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) -> Void in
            self.api.SendReport(["report_type":"Ahlaksyz mowzuk","image":self.imageName])
        })
        let narkotik = UIAlertAction(title: "Narkotika ündewi", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) -> Void in
            self.api.SendReport(["report_type":"Narkotika ündewi","image":self.imageName])
        })
        let porn = UIAlertAction(title: "Çaga pornografiýasy", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) -> Void in
            self.api.SendReport(["report_type":"Çaga pornografiýasy","image":self.imageName])
        })
        let extremism = UIAlertAction(title: "Ekstrimizm öňe sürmek", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) -> Void in
            self.api.SendReport(["report_type":"Ekstrimizm öňe sürmek","image":self.imageName])
        })
        let yowuz = UIAlertAction(title: "Ýowuzlyk", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) -> Void in
            self.api.SendReport(["report_type":"Ýowuzlyk","image":self.imageName])
        })
        let kemsidiji = UIAlertAction(title: "Kemsidiji surat", style: UIAlertActionStyle.Default, handler: {
            (action:UIAlertAction) -> Void in
            self.api.SendReport(["report_type":"Kemsidiji mowzuk","image":self.imageName])
        })
        let cancelAction = UIAlertAction(title: "Beset", style: UIAlertActionStyle.Cancel, handler: nil)
        
        shareMenu.addAction(spam)
        shareMenu.addAction(yowuz)
        shareMenu.addAction(insult)
        shareMenu.addAction(narkotik)
        shareMenu.addAction(kemsidiji)
        shareMenu.addAction(porn)
        shareMenu.addAction(extremism)
        shareMenu.addAction(cancelAction)
        
        self.nav.presentViewController(shareMenu, animated: true, completion: nil)
    }
  
}
extension UserHeaderView: APIProtocol {
    func success(success: Bool, resultsArr: NSArray?, results: NSDictionary?) {
        if success {
            SweetAlert().showAlert("Üstünlikli!", subTitle: "Habaryňyz üstünlikli ugradyldy we tiz wagtyň içinde serediler", style: AlertStyle.Success)
        }else{
            SweetAlert().showAlert("Ýalňyşlyk", subTitle: "Ýalňyşlyk ýüze çykdy.", style: AlertStyle.Error)
        }
    }
}
