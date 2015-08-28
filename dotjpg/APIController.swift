//
//  APIController.swift
//  dotjpg
//
//  Created by Atakishiyev Orazdurdy on 8/1/15.
//  Copyright (c) 2015 orazz. All rights reserved.
//

import Foundation

@objc
protocol APIProtocol {
    func success(success: Bool, resultsArr:NSArray?, results:NSDictionary?)
}

class APIController {
    
    var delegate: APIProtocol?
    var err: NSError?
    let manager: AFHTTPRequestOperationManager
    private(set) var token: String
    
    init() {
        token = UIDevice.currentDevice().identifierForVendor.UUIDString
        var url:NSURL = NSURL(string:Config.SERVER)!
        manager = AFHTTPRequestOperationManager(baseURL: url)
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as Set<NSObject>
        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/plain", "text/html", "application/json"]) as Set<NSObject>
    }
    
    func clientRequest(params: Dictionary<String, AnyObject>, objectForKey: String!) {
        var parametrs = params
        var error: NSError?
        parametrs["session_id"] = token

        manager.POST("", parameters: parametrs, success: {(operation: AFHTTPRequestOperation!,
            response: AnyObject!) in
            if let data = response as? NSData {
                if let json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error:&error) as? NSDictionary {
                    if objectForKey != nil {
                        if let results = json.valueForKey(objectForKey) as? NSArray {
                           self.delegate?.success(true, resultsArr: results, results: nil)
                        }
                    }
                }
            }
            }, failure: {(operation:AFHTTPRequestOperation!, error:NSError!) in
                println("ERROR:"+error.localizedDescription)
                self.delegate?.success(false, resultsArr: nil, results: nil)
        })
    }
    
    func imageUploader(params:Dictionary<String, AnyObject>, fileURLs: [NSURL], names: [String]){
        var parametrs = params
        parametrs["session_id"] = token
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        manager.POST("", parameters: parametrs,
            constructingBodyWithBlock: { (data: AFMultipartFormData!) in
                for var i = 0; i < fileURLs.count; i++ {

                    var res = data.appendPartWithFileURL(fileURLs[i], name: "images[\(names[i])]", fileName: names[i], mimeType: "image/jpeg", error: nil)
                    
                    // println("was file added properly to the body? \(res) ")
                }
            },
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) in
                //println("Yes thies was a success")
                    var json = NSJSONSerialization.JSONObjectWithData(response as! NSData, options: .MutableLeaves, error: &self.err) as? NSDictionary
                    self.delegate?.success(true, resultsArr: nil, results: json)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                //println("We got an error here.. \(error.localizedDescription)")
                self.delegate?.success(false, resultsArr: nil, results: nil)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
}