//
//  ViewPhotoVC.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/3/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import UIKit

class ViewPhotoVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var api: APIController!
    var images = [Images]()
    private (set)var headerViewHeight: CGFloat = 200.0
    var image: UIImage!
    var links = [String,String]()
    var imgURL: NSURL!
    private (set)var header: UIView!
    private (set)var avatarImage: UIImageView!
    private (set)var headerImageView: UIImageView!
    
    var share: FloatingButton!
    var offset_HeaderStop:CGFloat = 40.0;
    var offset_B_LabelHeader:CGFloat = 95.0;
    var distance_W_LabelHeader:CGFloat = 35.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView!.estimatedRowHeight = 100
        tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorColor = UIColor.MKColor.Teal
        self.header = UIView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: 0))
        UserHeaderView(image: image, height: headerViewHeight, inView: tableView, nav:self.navigationController, imgURL: imgURL)
        var img = images[0]
        links = [("",""),("Göni link", img.image_url), ("HTML","<a href=\"\(img.image_url)\"><img src=\"\(img.image_url)\"/></a>"), ("Markdown","[![image](\(img.image_url))](\(img.image_url))"),("bbcode","[url=\(img.image_url)][img]\(img.image_url)[/img][/url]")]
        
        self.view.addSubview(header)
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.header.frame.size.height))
        
        self.view.addSubview(self.tableView)
        
        self.share = FloatingButton(image: UIImage(named: "ic_share"), backgroundColor: UIColor.MKColor.Teal)
        self.share.addTarget(self, action: Selector("shareImage:"), forControlEvents: .TouchUpInside)
        self.share.frame.origin.y = -30
        self.share.frame.origin.x = self.header.frame.width - self.share.frame.width - 10
        self.share.clipsToBounds = true
        
        self.headerImageView = UIImageView(frame: self.header.frame)
   
        self.headerImageView.image = image
        self.headerImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.header.addSubview(self.headerImageView)
        self.header.clipsToBounds = true
        self.tableView.addSubview(share)
        
        if self.image == nil {
            self.share.enabled = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //self.navigationController?.disableRadialSwipe()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
        self.navigationController?.navigationBar.hidden = false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    func shareImage(sender: UIButton) {
        let firstActivityItem = "Suratlaryňyzy dotjpg.co bilen paýlaş"
        let secondActivityItem : NSURL = NSURL(string: self.images[0].image_url)!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, self.image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = (sender as UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.allZeros
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypeAddToReadingList,
            UIActivityTypePostToFlickr,
            UIActivityTypePostToVimeo,
            UIActivityTypePostToTencentWeibo
        ]
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
        
}
extension ViewPhotoVC: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        var selectedBack = UIView();
        selectedBack.backgroundColor = UIColor(hex: 0x9E9E9E, alpha: 0.1)
        
        if(indexPath.row == 0) {
            if let cellR = tableView.dequeueReusableCellWithIdentifier("Cell") as? ViewPhotoCell {
                var time = NSTimeInterval(images[0].timestamp)
                cellR.download.text = "\(NSDate(timeIntervalSince1970: time).relativeTime)"
                cell = cellR
            }
        }else{
            if let cellR = tableView.dequeueReusableCellWithIdentifier("CellLinks") as? ViewPhotoCellLinks {
                cellR.titleLbl.text = links[indexPath.row].0
                cellR.link.text = links[indexPath.row].1
                var tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("copyTapped"))
                cellR.link.addGestureRecognizer(tapRecognizer)
                
                cell = cellR
            }
        }
        cell.selectedBackgroundView = selectedBack
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 0) {
            var selectedCell = self.tableView.cellForRowAtIndexPath(indexPath) as? ViewPhotoCell
            selectedCell?.activityIndicator.startAnimating()
            selectedCell?.timeIcon.hidden = true
            
            if image == nil {
                SweetAlert().showAlert("Ýalňyşlyk!", subTitle: "Täzeden synanşyp görüň", style: AlertStyle.Error)
            }else{
                UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
            }
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            selectedCell?.activityIndicator.stopAnimating()
            selectedCell?.timeIcon.hidden = false
        }else{
            UIPasteboard.generalPasteboard().string = self.images[0].image_url
            JLToast.makeText("Link nusgalandy.", delay: 0, duration: 2).show()
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafePointer<()>) {
        dispatch_async(dispatch_get_main_queue(), {
            SweetAlert().showAlert("Üstünlikli!", subTitle: "Suratyňyz üstünlikli indirildi", style: AlertStyle.Success)
        })
    }
    
    func copyTapped() {
        UIPasteboard.generalPasteboard().string = self.images[0].image_url
        JLToast.makeText("Link nusgalandy.", delay: 0, duration: 2).show()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var offset =  scrollView.contentOffset.y
        //animationForScroll(offset)
    }
    

    
    func animationForScroll(offset:CGFloat) {
        var headerTransform = CATransform3DIdentity
        var avatarTransform = CATransform3DIdentity
       
        var view = self.tableView.viewWithTag(101)
        
        if (offset < 0) {
            var headerScaleFactor = -(offset) / self.header.bounds.size.height
            var headerSizevariation = ((self.header.bounds.size.height * (1.0 + headerScaleFactor)) - self.header.bounds.size.height) / 2.0
            headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0)
            headerTransform = CATransform3DScale(headerTransform, 1.0, headerScaleFactor, 1.0 + headerScaleFactor)
            
            self.header.layer.transform = headerTransform
            
        }else{
            headerTransform = CATransform3DTranslate(headerTransform, 0, max(-offset_HeaderStop, -offset), 0)
            var buttonScaleFactor = (min(offset_HeaderStop, offset)) / self.share.bounds.size.height / 1.4
            var buttonSizeVariation = ((self.share.bounds.size.height * (1.0 + buttonScaleFactor)) - self.share.bounds.size.height) / 2.0
            avatarTransform = CATransform3DTranslate(avatarTransform, 0, buttonSizeVariation, 0)
            avatarTransform = CATransform3DScale(avatarTransform, 1.0 - buttonScaleFactor, 1.0 - buttonScaleFactor, 0)
            
            if (offset <= offset_HeaderStop) {
                if (self.share.layer.zPosition <= self.headerImageView.layer.zPosition) {
                    self.header.layer.zPosition = 0
                }
            }else{
                if(self.share.layer.zPosition >= self.headerImageView.layer.zPosition) {
                    self.header.layer.zPosition = 2
                }
            }
            self.header.layer.transform = headerTransform
            self.share.layer.transform = avatarTransform
        }
    }
    
}
class ViewPhotoCell: UITableViewCell {
    @IBOutlet weak var timeIcon: UIImageView!
    @IBOutlet weak var download: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
}

class ViewPhotoCellLinks: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    private var bottomBorderLayer: CALayer?
    @IBOutlet weak var link: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
}

