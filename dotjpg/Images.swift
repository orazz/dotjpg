//
//  Images.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/1/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import Foundation

class Images {
    
    var image:String
    var height:Int
    var width:Int
    var image_url:String
    var timestamp:Int
    
    init(image:String, height:Int, width:Int, image_url:String, timestamp:Int){
        self.image = image
        self.height = height
        self.width = width
        self.image_url = image_url
        self.timestamp = timestamp
    }
    
    class func ImagesWithJSON(results: NSArray) -> [Images] {
        var images = [Images]()
        if results.count > 0 {
            for result in results {
                let image = result["image"] as? String
                let height = result["height"] as! Int
                let width = result["width"] as! Int
                let image_url = "http://dotjpg.co/" + (result["image"] as? String)!
                let timestamp = result["timestamp"] as! Int
                
                let newImage = Images(image: image!, height: height, width: width, image_url: image_url, timestamp: timestamp)
                images.append(newImage)
            }
        }
        
        return images
    }
}