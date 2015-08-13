//
//  PhotoVC.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/1/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import UIKit

let reuseIdentifier = "photoCell"

class PhotoVC: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newPhoto: FloatingButton!
    @IBOutlet weak var activityIndicator: KMActivityIndicator!
    @IBOutlet weak var loadinLbl: UILabel!
    
    private(set) var previousTableViewYOffset : CGFloat?
    private(set) var previousScrollViewYOffset: CGFloat = 0
    var api: APIController!
    var images = [Images]()
    var bounds = UIScreen.mainScreen().bounds
    
    var photoURLs = [NSURL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.translucent = true
        newPhoto.setup()
        activityIndicator.startAnimating()
        self.api = APIController()
        self.api.delegate = self
        self.api.clientRequest(["controller":"image", "action":"getAllSpecial", "page":0], objectForKey: "data")
        let cellWidth = (UIScreen.mainScreen().bounds.width) - 15
        let cellLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        
        collectionView!.registerNib(UINib(nibName: "PhotoCollectionView", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: reuseIdentifier)
        let tabBar = self.tabBarController?.tabBar;
        tabBar?.barTintColor = UIColor.MKColor.Teal
        tabBar?.tintColor = UIColor.whiteColor()
        newPhoto.tintColor = UIColor.whiteColor()
        navigationItem.title = "POPULAR"
        var exampleImage = UIImage(named: "ic_image")?.imageWithRenderingMode(.AlwaysTemplate)
        newPhoto.addTarget(self, action: Selector("selectMultipleImage:"), forControlEvents: .TouchUpInside)
        newPhoto.setImage(exampleImage, forState: UIControlState.Normal)
        newPhoto.tintColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func scaleUIImageToSize(let image: UIImage, let size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        previousTableViewYOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var heightOfTabBar = self.tabBarController?.tabBar.frame.height
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        
        
        var frame: CGRect = self.navigationController!.navigationBar.frame
        var frameOfTabBar: CGRect = self.tabBarController!.tabBar.frame
        var size:CGFloat = frame.size.height - 21

        var sizeT:CGFloat = CGFloat(bounds.height)
        
        var framePercentageHidden:CGFloat = ((20 - frame.origin.y) / (frame.size.height - 1))
        var scrollOffset:CGFloat = scrollView.contentOffset.y
        var scrollDiff:CGFloat = scrollOffset - self.previousScrollViewYOffset
        var scrollHeight:CGFloat = scrollView.frame.size.height;
        var scrollContentSizeHeight:CGFloat = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        if (scrollOffset <= -scrollView.contentInset.top) {
            frame.origin.y = 20;
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.newPhoto.alpha = 1
                }, completion: { finished in
            })
        } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
            frame.origin.y = -size;
            frameOfTabBar.origin.y = sizeT - CGFloat(heightOfTabBar!)
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.newPhoto.alpha = 1
                }, completion: { finished in
            })
        } else {
            frame.origin.y = min(20, max(-size, frame.origin.y - scrollDiff))
    
            frameOfTabBar.origin.y = max(sizeT - CGFloat(heightOfTabBar!), min(sizeT, frameOfTabBar.origin.y + scrollDiff))
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.newPhoto.alpha = 0
                }, completion: { finished in
            })
        }
        self.tabBarController?.tabBar.frame = frameOfTabBar
        self.navigationController?.navigationBar.frame = frame
        self.updateBarButtonItems(1 - framePercentageHidden)
        self.previousScrollViewYOffset = scrollOffset

    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.stoppedScrolling()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            self.stoppedScrolling()
        }
    }
    
    func stoppedScrolling(){
        var frame = self.navigationController?.navigationBar.frame
        self.tabBarController?.tabBar.frame.origin.y = CGFloat(bounds.height) - self.tabBarController!.tabBar.frame.height
        if(frame?.origin.y < 20){
            var height = frame?.size.height
            self.animateNavBarTo(height! - 24)
        }
    }
    
    func updateBarButtonItems(alpha:CGFloat){
       // var leftBarButtonItems = [self.navigationItem.leftBarButtonItem!]
        //for barItem in leftBarButtonItems {
         //   barItem.customView?.alpha = alpha
        //}
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(alpha)]
        self.navigationItem.titleView?.alpha = alpha
        self.navigationController?.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor.colorWithAlphaComponent(alpha)
        
    }
    
    func animateNavBarTo(y: CGFloat){
        UIView.animateWithDuration(0.2, animations: {
            var frame = self.navigationController?.navigationBar.frame
            var alpha: CGFloat = (frame?.origin.y >= y ? 0 : 1)
            frame?.origin.y = y
            self.navigationController?.navigationBar.frame = frame!
            
            self.updateBarButtonItems(alpha)
        })
    }
    
    func selectMultipleImage(sender:UIButton) {
        
        var elcPikcer = ELCImagePickerController()
        elcPikcer.maximumImagesCount = 6; //Set the maximum number of images to select, defaults to 4
        //elcPikcer.returnsOriginalImage = false; //Only return the fullScreenImage, not the fullResolutionImage
        //elcPikcer.returnsImage = true; //Return UIimage if YES. If NO, only return asset location information
        //elcPikcer.onOrder = true; //For multiple image selection, display and return selected order of images
        elcPikcer.imagePickerDelegate = self;
        
        self.presentViewController(elcPikcer, animated: true, completion: nil)
        
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //var selectImage = storyboard.instantiateViewControllerWithIdentifier("MulipleImageSelectVC") as! MultipleImageSelectVC
        
        //self.navigationController?.pushViewController(selectImage, animated: true)
       
        // self.navigationController?.radialPushViewController(selectImage,startFrame: sender.frame,duration:0.3,transitionCompletion: { () -> Void in
            
            
            
        //})
    }
}

extension PhotoVC: ELCImagePickerControllerDelegate {
    func elcImagePickerController(picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [AnyObject]!) {
        var i = 0
        var names = [String]()
        for dictionary in info {
            //var image = dictionary[UIImagePickerControllerOriginalImage] as! UIImage//ELC packages its dictionaries with the same key as UIImagePicker
           // var fileData = UIImagePNGRepresentation(image);
    
            // ... the rest of your code ... //
            
            let imageURL = dictionary[UIImagePickerControllerReferenceURL] as! NSURL
            
            let imageName = "\(i)-\(imageURL.path!.lastPathComponent)"
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first as! String
            var localPath = documentDirectory.stringByAppendingPathComponent(imageName)
            
            
            let image = dictionary[UIImagePickerControllerOriginalImage] as! UIImage
            let data = UIImageJPEGRepresentation(image, 0.1)
            data.writeToFile(localPath, atomically: true)
            
            let imageData = NSData(contentsOfFile: localPath)!
            self.photoURLs.append(NSURL(fileURLWithPath: localPath)!)
            names.append("\(i)_image")
            i++
        }
        
        self.api.imageUploader(["controller":"image","action":"fileUpload"], fileURLs: self.photoURLs, names: names)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func elcImagePickerControllerDidCancel(picker: ELCImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PhotoVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        var image = self.images[indexPath.row]

        cell.cellImage.setImageWithURL(NSURL(string: image.image_url), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        var title = image.image.componentsSeparatedByString(".")
        cell.cellTitle.text = (title.count > 0) ? title[0] : ""
        var time: NSTimeInterval = NSTimeInterval(image.timestamp)
        cell.cellDate.text = "\(NSDate(timeIntervalSince1970: time).relativeTime)"
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.stoppedScrolling()
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var viewPhoto = self.storyboard?.instantiateViewControllerWithIdentifier("ViewPhotoVC") as! ViewPhotoVC
            viewPhoto.image = cell.cellImage.image
            viewPhoto.images = [images[indexPath.row]]
            self.navigationController?.pushViewController(viewPhoto, animated: true)
        }
    }
    
}

extension PhotoVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let targetWidth: CGFloat = (self.collectionView.bounds.width - 2 * 8)
        var image = self.images[indexPath.row]
        var cell = NSBundle.mainBundle().loadNibNamed("PhotoCollectionView", owner: self, options: nil)[0] as? PhotoCollectionViewCell
        
        var scaleFactor = targetWidth / CGFloat(image.width)
        var newHeight = CGFloat(image.height) * scaleFactor
        var newWidth = CGFloat(image.width) * scaleFactor
        var size = CGSize(width: newWidth, height: newHeight)

        return size
    }
}

extension PhotoVC: APIProtocol {
    func success(success: Bool, resultsArr:NSArray?, results:NSDictionary?) {
        if success {
            self.images = Images.ImagesWithJSON(resultsArr!)
            self.collectionView.reloadData()
            activityIndicator.stopAnimating()
            loadinLbl.hidden = true
        }
    }
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.contentMode = .ScaleAspectFit
    }
}
