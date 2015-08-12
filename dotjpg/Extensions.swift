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
extension NSDate {
    func yearsFrom(date:NSDate)   -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitYear, fromDate: date, toDate: self, options: nil).year
    }
    func monthsFrom(date:NSDate)  -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitMonth, fromDate: date, toDate: self, options: nil).month
    }
    func weeksFrom(date:NSDate)   -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitWeekOfYear, fromDate: date, toDate: self, options: nil).weekOfYear
    }
    func daysFrom(date:NSDate)    -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitDay, fromDate: date, toDate: self, options: nil).day
    }
    func hoursFrom(date:NSDate)   -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitHour, fromDate: date, toDate: self, options: nil).hour
    }
    func minutesFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitMinute, fromDate: date, toDate: self, options: nil).minute
    }
    func secondsFrom(date:NSDate) -> Int {
        return NSCalendar.currentCalendar().components(.CalendarUnitSecond, fromDate: date, toDate: self, options: nil).second
    }
    var relativeTime: String {
        let now = NSDate()
        let humanDate = GetHumanDate(self, "off")
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
    var today: String = form.stringFromDate(NSDate())
    var checkDate: String = form.stringFromDate(date)
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd hh:mm:s"
    var date: String = formatter.stringFromDate(date)
    
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
        return "\(time)"
    }
    
    if(showtime == "on"){
        return "\(d) \(month[m]!) \(y) \(time)"
    }else{
        return "\(d) \(month[m]!) \(y)"
    }
}