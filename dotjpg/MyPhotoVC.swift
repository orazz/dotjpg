//
//  MyPhotoVC.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/25/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import UIKit

class MyPhotoVC: UIViewController, UIScrollViewDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var notFound: UILabel!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var floatingBtn: FloatingButton!
    @IBOutlet weak var activityIndicator: KMActivityIndicator!
    @IBOutlet weak var loadinLbl: UILabel!
    
    private(set) var previousTableViewYOffset : CGFloat?
    private(set) var previousScrollViewYOffset: CGFloat = 0
    private(set) var loadMoreStatus = false
    private(set) var pagination = 1
    private(set) var isRefresh = false
    
    var api: APIController!
    var images = [Images]()
    var bounds = UIScreen.mainScreen().bounds
    var photoURLs = [NSURL]()
    var load:Bool = false
    
    weak var weakSelf: MyPhotoVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMyPhoto()
        floatingBtn.setup()
        activityIndicator.startAnimating()
        let cellWidth = (UIScreen.mainScreen().bounds.width) - 15
        let cellLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        cellLayout.itemSize = CGSize(width: cellWidth, height: cellWidth)
        collectionView.hidden = true
        collectionView!.registerNib(UINib(nibName: "PhotoCollectionView", bundle: NSBundle.mainBundle()), forCellWithReuseIdentifier: reuseIdentifier)
        let tabBar = self.tabBarController?.tabBar;
        tabBar?.barTintColor = UIColor.MKColor.Teal
        tabBar?.tintColor = UIColor.whiteColor()
        floatingBtn.tintColor = UIColor.whiteColor()
        navigationItem.title = "Ýüklenenler"
        let exampleImage = UIImage(named: "ic_add_image")?.imageWithRenderingMode(.AlwaysTemplate)
        floatingBtn.addTarget(self, action: Selector("selectMultipleImage:"), forControlEvents: .TouchUpInside)
        floatingBtn.setImage(exampleImage, forState: UIControlState.Normal)
        floatingBtn.tintColor = UIColor.whiteColor()
        
        weakSelf = self as MyPhotoVC
        self.collectionView.headerViewRefreshAnimationStatus(.headerViewRefreshArrowAnimation, images: [])
        
       self.collectionView.toLoadMoreAction({ () -> () in
            if ( !self.loadMoreStatus ) {
                self.loadMoreStatus = true
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    self.api.clientRequest(["controller":"image", "action":"getAll", "page":self.pagination], objectForKey: "data")
                }
            }
        })
        
        self.collectionView.nowRefresh({ () -> Void in
            delay(2.0, closure: { () -> () in})
            delay(2.0, closure: { () -> () in
                self.getMyPhoto()
            })
        })
        
        self.collectionView.hide(true)
    }
    
    func getMyPhoto() {
        self.isRefresh = true
        self.api = APIController()
        self.api.delegate = self
        self.api.clientRequest(["controller":"image", "action":"getAll", "page":0], objectForKey: "data")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.images.count <= 0 {
            getMyPhoto()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        var frame = self.navigationController?.navigationBar.frame
        frame?.origin.y = 20
        self.navigationController?.navigationBar.frame = frame!
        updateBarButtonItems(1)
        super.viewDidDisappear(animated)
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
    
    //MARK: - Navigation Bar and TabBar hide show
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        previousTableViewYOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let heightOfTabBar = self.tabBarController?.tabBar.frame.height
        
        let currentOffset = scrollView.contentOffset.y

        var frame: CGRect = self.navigationController!.navigationBar.frame
        var frameOfTabBar: CGRect = self.tabBarController!.tabBar.frame
        let size:CGFloat = frame.size.height - 21
        
        let sizeT:CGFloat = CGFloat(bounds.height)
        
        let framePercentageHidden:CGFloat = ((20 - frame.origin.y) / (frame.size.height - 1))
        let scrollOffset:CGFloat = scrollView.contentOffset.y
        let scrollDiff:CGFloat = scrollOffset - self.previousScrollViewYOffset
        let scrollHeight:CGFloat = scrollView.frame.size.height;
        let scrollContentSizeHeight:CGFloat = scrollView.contentSize.height + scrollView.contentInset.bottom
        
        if (scrollOffset <= -scrollView.contentInset.top) {
            frame.origin.y = 20;
            
        } else if ((scrollOffset + scrollHeight) >= scrollContentSizeHeight) {
            frame.origin.y = -size;
            frameOfTabBar.origin.y = sizeT - CGFloat(heightOfTabBar!)
            
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.floatingBtn.alpha = 1
                }, completion: { finished in
            })
        } else {
            frame.origin.y = min(20, max(-size, frame.origin.y - scrollDiff))
            
            frameOfTabBar.origin.y = max(sizeT - CGFloat(heightOfTabBar!), min(sizeT, frameOfTabBar.origin.y + scrollDiff))
           
        }
        
        if (self.previousScrollViewYOffset <= currentOffset) {
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.floatingBtn.alpha = 0
                }, completion: { finished in
            })
        }else{
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseOut, animations: {
                self.floatingBtn.alpha = 1
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
        let frame = self.navigationController?.navigationBar.frame
        self.tabBarController?.tabBar.frame.origin.y = CGFloat(bounds.height) - self.tabBarController!.tabBar.frame.height
        if(frame?.origin.y < 20){
            let height = frame?.size.height
            self.animateNavBarTo(height! - 24)
        }
    }
    
    func updateBarButtonItems(alpha:CGFloat){
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(alpha)]
        self.navigationItem.titleView?.alpha = alpha
        self.navigationController?.navigationBar.tintColor = self.navigationController?.navigationBar.tintColor.colorWithAlphaComponent(alpha)
    }
    
    func animateNavBarTo(y: CGFloat){
        UIView.animateWithDuration(0.2, animations: {
            var frame = self.navigationController?.navigationBar.frame
            let alpha: CGFloat = (frame?.origin.y >= y ? 0 : 1)
            frame?.origin.y = y
            self.navigationController?.navigationBar.frame = frame!
            
            self.updateBarButtonItems(alpha)
        })
    }
    
    func selectMultipleImage(sender:UIButton) {
        
        let elcPikcer = ELCImagePickerController()
        elcPikcer.maximumImagesCount = 6; //Set the maximum number of images to select, defaults to 4
        elcPikcer.imagePickerDelegate = self;
        
        self.presentViewController(elcPikcer, animated: true, completion: nil)
    }
}
extension MyPhotoVC: ELCImagePickerControllerDelegate {
    
    //MARK: - ImagePikcer
    func elcImagePickerController(picker: ELCImagePickerController!, didFinishPickingMediaWithInfo info: [AnyObject]!) {
        var i = 0
        var names = [String]()
        for dictionary in info {
            let imageURL = dictionary[UIImagePickerControllerReferenceURL] as! NSURL
            
            let imageName = "\(i)-\((imageURL.path! as NSString).lastPathComponent)"
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
            let localPath = ("\(documentDirectory!)" as NSString).stringByAppendingPathComponent(imageName)
            
            
            let image = dictionary[UIImagePickerControllerOriginalImage] as! UIImage
            let data = UIImageJPEGRepresentation(image, 0.1)
            data!.writeToFile(localPath, atomically: true)

            self.photoURLs.append(NSURL(fileURLWithPath: localPath))
            names.append("\(i)_image")
            i++
        }
        
        let pc = self.storyboard!.instantiateViewControllerWithIdentifier("SelectedImagesForUploadVC") as! SelectedImagesForUploadVC
        pc.names = names
        pc.urls = self.photoURLs
        
        dismissViewControllerAnimated(true, completion: {
            () -> () in
            self.navigationController!.pushViewController(pc, animated: true)
        })
    }
    
    func elcImagePickerControllerDidCancel(picker: ELCImagePickerController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MyPhotoVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    //MARK: - CollectionView
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        let image = self.images[indexPath.row]
        
        cell.cellImage.setImageWithURL(NSURL(string: image.image_url), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        var title = image.image.componentsSeparatedByString(".")
        cell.cellTitle.text = (title.count > 0) ? title[0] : ""
        let time: NSTimeInterval = NSTimeInterval(image.timestamp)
        cell.cellDate.text = "\(NSDate(timeIntervalSince1970: time).relativeTime)"
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.stoppedScrolling()
        
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? PhotoCollectionViewCell {
            let viewPhoto = self.storyboard?.instantiateViewControllerWithIdentifier("ViewPhotoVC") as! ViewPhotoVC
            viewPhoto.image = cell.cellImage.image
            viewPhoto.images = [images[indexPath.row]]
            viewPhoto.imgURL = NSURL(string: self.images[indexPath.row].image_url)
            self.navigationController?.pushViewController(viewPhoto, animated: true)
        }
    }
    
}

extension MyPhotoVC : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let targetWidth: CGFloat = (self.collectionView.bounds.width - 2 * 8)
        let image = self.images[indexPath.row]
        //var cell = NSBundle.mainBundle().loadNibNamed("PhotoCollectionView", owner: self, options: nil)[0] as? PhotoCollectionViewCell
        
        let scaleFactor = targetWidth / CGFloat(image.width)
        let newHeight = CGFloat(image.height) * scaleFactor
        let newWidth = CGFloat(image.width) * scaleFactor
        let size = CGSize(width: newWidth, height: newHeight)
        
        return size
    }
    
}

extension MyPhotoVC: APIProtocol {
    func success(success: Bool, resultsArr:NSArray?, results:NSDictionary?) {
        if success {
            if resultsArr?.count > 0 {
                self.collectionView.hidden = false
                if isRefresh {
                    self.images = Images.ImagesWithJSON(resultsArr!)
                    self.pagination = 1
                    self.loadMoreStatus = false
                }else{
                    self.images += Images.ImagesWithJSON(resultsArr!)
                    self.loadMoreStatus = false
                    self.pagination++
                }
                activityIndicator.stopAnimating()
                loadinLbl.hidden = true
                self.isRefresh = false
                weakSelf?.collectionView.reloadData()
                weakSelf?.collectionView.doneRefresh()
                collectionView.hide(false)
            }else{
                self.loadingView.hidden = true
                loadMoreStatus = true
                weakSelf?.collectionView.doneRefresh()
                //weakSelf?.collectionView.endLoadMoreData()
                collectionView.hide(true)
                activityIndicator.startAnimating()
                loadinLbl.hidden = false
            }
        }else{
            self.loadingView.hidden = true
            self.images = []
            collectionView.reloadData()
            collectionView.hide(true)
            activityIndicator.startAnimating()
            loadinLbl.hidden = false
        }

    }
}
extension MyPhotoVC: SelectedImagesDelegate {
    func uploded(update: Bool) {
        if update {
             delay(3, closure: ({self.getMyPhoto()}))
        }
    }
}
