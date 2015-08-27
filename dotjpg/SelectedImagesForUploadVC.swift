//
//  SelectedImagesForUploadVC.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/13/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import Foundation
import UIKit

class SelectedImagesForUploadVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var names = [String]()
    var urls = [NSURL]()
    var api: APIController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.api = APIController()
        self.api.delegate = self
        
        var doneBtn = UIBarButtonItem(title: "Ýükle", style: .Plain, target: self, action: Selector("UploadImages"))
        self.navigationItem.rightBarButtonItem = doneBtn
    }
    
    func UploadImages() {
        if self.urls.count <= 0 {
            self.navigationController?.popViewControllerAnimated(true)
        }else{
            self.api.imageUploader(["controller":"image","action":"fileUpload"], fileURLs: self.urls, names: names)
            var xhAmazing = XHAmazingLoadingView(type: XHAmazingLoadingAnimationType.Skype)
            xhAmazing.loadingTintColor = UIColor.MKColor.Teal
            xhAmazing.backgroundTintColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            xhAmazing.frame = self.view.bounds
            self.view.addSubview(xhAmazing)
            xhAmazing.startAnimating()
        }
    }
    
}

extension SelectedImagesForUploadVC: APIProtocol {
    func success(success: Bool, resultsArr: NSArray?, results: NSDictionary?) {
        if success {
            self.navigationController?.popViewControllerAnimated(true)
            self.tabBarController?.selectedIndex = 1
            SweetAlert().showAlert("Üstünlikli!", subTitle: "Suratyňyz üstünlikli ýüklenildi", style: AlertStyle.Success)
        }else{
            SweetAlert().showAlert("Ýalňyşlyk", subTitle: "Täzeden synanşyp görüň", style: AlertStyle.Warning)
        }
    }
}

extension SelectedImagesForUploadVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! SelectedImagesCell
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cellR = cell as? SelectedImagesCell {
            cellR.imageSelected.image = UIImage(data: NSData(contentsOfURL: urls[indexPath.row])!)
            
            var attr:NSDictionary? = NSFileManager.defaultManager().attributesOfItemAtPath(urls[indexPath.row].path!, error: nil)
            
            if let _attr = attr {
                var size:Double = (Double(_attr.fileSize())/1024)
                cellR.imageSize.text = "Suratyň ölçegi: " + size.format(".2") + " KB."
                cellR.imageFormat.text = "Suratyň görnüşi: \(urls[indexPath.row].pathExtension!)"
            }
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let delete = UITableViewRowAction(style: .Normal, title: "poz") { action, index in
            self.urls.removeAtIndex(indexPath.row)
            self.names.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
        delete.backgroundColor = UIColor.redColor()

        return [delete]
    }
}

class SelectedImagesCell: UITableViewCell {
    
    @IBOutlet weak var imageSelected: UIImageView!
    @IBOutlet weak var imageSize: UILabel!
    @IBOutlet weak var imageFormat: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}