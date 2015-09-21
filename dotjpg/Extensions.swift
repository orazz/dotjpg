//
//  Extensions.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/3/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xFF)) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    struct MKColor {
        static let Red = UIColor(hex: 0xF44336)
        static let Pink = UIColor(hex: 0xE91E63)
        static let Purple = UIColor(hex: 0x9C27B0)
        static let DeepPurple = UIColor(hex: 0x67AB7)
        static let Indigo = UIColor(hex: 0x3F51B5)
        static let Blue = UIColor(hex: 0x2196F3)
        static let LightBlue = UIColor(hex: 0x03A9F4)
        static let Cyan = UIColor(hex: 0x00BCD4)
        static let Teal = UIColor(hex: 0x009688)
        static let Green = UIColor(hex: 0x4CAF50)
        static let LightGreen = UIColor(hex: 0x8BC34A)
        static let Lime = UIColor(hex: 0xCDDC39)
        static let Yellow = UIColor(hex: 0xFFEB3B)
        static let Amber = UIColor(hex: 0xFFC107)
        static let Orange = UIColor(hex: 0xFF9800)
        static let DeepOrange = UIColor(hex: 0xFF5722)
        static let Brown = UIColor(hex: 0x795548)
        static let Grey = UIColor(hex: 0x9E9E9E)
        static let BlueGrey = UIColor(hex: 0x607D8B)
    }
    var pixelImage: UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
        
        self.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension Double {
    func format(f: String) -> String {
        return NSString(format: "%\(f)f", self) as String
    }
}

func imageWithImage(sourceImage: UIImage, i_width:CGFloat) -> UIImage {
    let oldWidth = sourceImage.size.width
    let scaleFactor = i_width / oldWidth
    let newHeight = sourceImage.size.height * scaleFactor
    let newWidth = oldWidth * scaleFactor
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
    sourceImage.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
}
extension NSDate {
    func yearsFrom(date:NSDate)   -> Int {
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate)  -> Int {
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate)   -> Int {
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate)    -> Int {
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate)   -> Int {
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    var relativeTime: String {
        let now = NSDate()
        let humanDate = GetHumanDate(self, showtime: "off")
        if now.yearsFrom(self)   > 0 {
            //return now.yearsFrom(self).description  + " ýyl"  + { return now.yearsFrom(self)   > 1 ? "" : "" }() + " öň, \(humanDate)"
            return "\(humanDate)"
        }
        if now.monthsFrom(self)  > 0 {
            //return now.monthsFrom(self).description + " aý " + { return now.monthsFrom(self)  > 1 ? "" : "" }() + " öň, \(humanDate)"
            return "\(humanDate)"
        }
        if now.weeksFrom(self)   > 0 {
            //return now.weeksFrom(self).description  + " hepde"  + { return now.weeksFrom(self)   > 1 ? "" : "" }() + " öň, \(humanDate)"
            return "\(humanDate)"
        }
        if now.daysFrom(self)    > 0 {
            if daysFrom(self) == 1 { return "Düýn" }
            //return now.daysFrom(self).description + " gün öň, \(humanDate)"
            return "\(humanDate)"
        }
        if now.hoursFrom(self)   > 0 {
            //return "\(now.hoursFrom(self)) sagat"     + { return now.hoursFrom(self) > 1 ? "" : "" }() + " öň, \(humanDate)"
            return "\(humanDate)"
        }
        if now.minutesFrom(self) > 0 {
            return "\(now.minutesFrom(self)) minut" + { return now.minutesFrom(self) > 1 ? "" : "" }() + " öň, \(humanDate)"
        }
        if now.secondsFrom(self) > 0 {
            if now.secondsFrom(self) < 15 { return "Şu wagtjyk"  }
            return "\(now.secondsFrom(self)) sekund" + { return now.secondsFrom(self) > 1 ? "" : "" }() + " öň, \(humanDate)"
        }
        return ""
    }
}

func GetHumanDate(date: NSDate, showtime: String?) -> String
{
    let form = NSDateFormatter()
    form.dateFormat = "yyyy-MM-dd"
    let today: String = form.stringFromDate(NSDate())
    let checkDate: String = form.stringFromDate(date)
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm:s"
    let date: String = formatter.stringFromDate(date)
    
    let y: String = (date as NSString).substringToIndex(4)
    let m: String = (date as NSString).substringWithRange(NSMakeRange(5, 2))
    let d: String = (date as NSString).substringWithRange(NSMakeRange(8, 2))
    let time: String = (date as NSString).substringWithRange(NSMakeRange(11, 5))
    
    var month: [String: String] =
    ["01" : "Ýan.",
        "02": "Few.",
        "03": "Mar.",
        "04": "Apr.",
        "05": "Maý",
        "06": "Iýun",
        "07": "Iýul",
        "08": "Awg.",
        "09": "Sen.",
        "10": "Okt.",
        "11": "Noý.",
        "12": "Dek."]
    
    if(today == checkDate){
        return "Şu gün(\(time))"
    }
    
    if(showtime == "on"){
        return "\(d) \(month[m]!) \(y) \(time)"
    }else{
        return "\(d) \(month[m]!) \(y)"
    }
}

public func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
