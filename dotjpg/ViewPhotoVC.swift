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
    var headerViewHeight: CGFloat = 200.0
    var image: UIImage!
    var links = [String,String]()
    
    var header: UIView!
    var avatarImage: UIImageView!
    var headerImageView: UIImageView!
    
    var share: FloatingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView!.estimatedRowHeight = 100
        tableView!.rowHeight = UITableViewAutomaticDimension
        self.tableView!.tableFooterView?.hidden = true
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.None
        UserHeaderView(image: image, height: headerViewHeight, inView: tableView, nav:self.navigationController)
        var img = images[0]
        links = [("",""),("Göni link", img.image_url), ("HTML","<a href=\"\(img.image_url)\"><img src=\"\(img.image_url)\"/></a>"), ("Markdown","[![image](\(img.image_url))](\(img.image_url))"),("bbcode","[url=\(img.image_url)][img]\(img.image_url)[/img][/url]")]
    
        self.header = UIView(frame: CGRect(x: self.view.frame.origin.x, y: self.view.frame.origin.y, width: self.view.frame.size.width, height: 0))
        self.view.addSubview(header)
        
        self.tableView.tableHeaderView = UIView(frame: CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.header.frame.size.height))
        self.view.addSubview(self.tableView)
        self.avatarImage = UIImageView(frame: CGRectMake(10, -30, 69, 69))
        self.avatarImage.image = image
        self.avatarImage.clipsToBounds = true
        
        self.share = FloatingButton(image: UIImage(named: "ic_share"), backgroundColor: UIColor.MKColor.Teal)
        self.share.frame.origin.y = -27
        self.share.frame.origin.x = self.header.frame.width - self.share.frame.width - 10
        self.share.clipsToBounds = true
        
        self.headerImageView = UIImageView(frame: self.header.frame)
   
        self.headerImageView.image = image
        self.headerImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.header.addSubview(self.headerImageView)
        self.header.clipsToBounds = true
        self.tableView.addSubview(share)
        
        self.avatarImage.layer.cornerRadius = 34.5;
        self.avatarImage.layer.borderWidth = 3;
        self.avatarImage.layer.borderColor = UIColor.whiteColor().CGColor

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
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
                cellR.download.text = "\(NSDate(timeIntervalSince1970: time).relativeTime)   ⬇︎Indir"
                cell = cellR
            }
        }else{
            if let cellR = tableView.dequeueReusableCellWithIdentifier("CellLinks") as? ViewPhotoCellLinks {
                cellR.titleLbl.text = links[indexPath.row].0
                cellR.textfield.text = links[indexPath.row].1
                cellR.textfield.delegate = self
                cell = cellR
            }
        }
        cell.selectedBackgroundView = selectedBack
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        UIPasteboard.generalPasteboard().string = self.images[0].image_url
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
class ViewPhotoCell: UITableViewCell {
    @IBOutlet weak var download: UILabel!
}

class ViewPhotoCellLinks: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var textfield: MKTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textfield.layer.borderColor = UIColor.clearColor().CGColor
        textfield.floatingPlaceholderEnabled = true
        textfield.tintColor = UIColor.orangeColor()
        textfield.rippleLocation = .Right
        textfield.cornerRadius = 0
        textfield.bottomBorderEnabled = true
        textfield.enabled = false
    }
}

