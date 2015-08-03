//
//  PhotoVC.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/1/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import UIKit

let reuseIdentifier = "photoCell"

class PhotoVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newPhoto: FloatingButton!
    
    var previousTableViewYOffset : CGFloat?
    private(set) var previousScrollViewYOffset: CGFloat = 0
    var api: APIController!
    
    var images = [Images]()
    //var images = ["1nearby.PNG", "JAkdhtLysS8.jpg", "temp..hhfnftwq.png", "FullSizeRender.jpg","BJ8vlACPzIE.jpg"]
    override func viewDidLoad() {
        super.viewDidLoad()
        newPhoto.setup()
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
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func imageWithImage(sourceImage: UIImage, i_width:CGFloat) -> UIImage {
        var oldWidth = sourceImage.size.width
        var scaleFactor = i_width / oldWidth
        var newHeight = sourceImage.size.height * scaleFactor
        var newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        sourceImage.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        var newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        previousTableViewYOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var bounds = UIScreen.mainScreen().bounds
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
            //frameOfTabBar.origin.y = sizeT
            
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
                //self.tabBarController?.tabBar.frame.origin.y = bounds.height
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
}

extension PhotoVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! PhotoCollectionViewCell
        var image = self.images[indexPath.row]

        cell.cellImage.setImageWithURL(NSURL(string: image.image_url), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        cell.cellTitle.text = image.image

        return cell
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
        }
    }
}

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.contentMode = .ScaleAspectFit
    }
}
