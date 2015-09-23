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
        token = UIDevice.currentDevice().identifierForVendor!.UUIDString
        let url:NSURL = NSURL(string:Config.SERVER)!
        manager = AFHTTPRequestOperationManager(baseURL: url)
        manager.responseSerializer = AFHTTPResponseSerializer()
        manager.responseSerializer.acceptableContentTypes = NSSet(objects: "application/json") as Set<NSObject>
        manager.responseSerializer.acceptableContentTypes = NSSet(array: ["text/plain", "text/html", "application/json"]) as Set<NSObject>
    }
    
    func clientRequest(params: Dictionary<String, AnyObject>, objectForKey: String!) {
        var parametrs = params
        parametrs["session_id"] = token

        manager.POST("", parameters: parametrs, success: {(operation: AFHTTPRequestOperation!,
            response: AnyObject!) in
            if let data = response as? NSData {
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves) as? NSDictionary {
                        if objectForKey != nil {
                            if let results = json.valueForKey(objectForKey) as? NSArray {
                               self.delegate?.success(true, resultsArr: results, results: nil)
                            }
                        }
                    }
                }catch{
                    
                }
            }
            }, failure: {(operation:AFHTTPRequestOperation!, error:NSError!) in
                print("ERROR:"+error.localizedDescription)
                self.delegate?.success(false, resultsArr: nil, results: nil)
                let alert = UIAlertView(title: "Internet ýok", message: "Ýene bir az wagtdan synanşyp görüň", delegate: self, cancelButtonTitle: "OK")
                alert.show()
        })
    }
    
    func imageUploader(params:Dictionary<String, AnyObject>, fileURLs: [NSURL], names: [String]){
        var parametrs = params
        parametrs["session_id"] = token
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

       manager.POST("", parameters: parametrs,
            constructingBodyWithBlock: { (data: AFMultipartFormData!) in
                for var i = 0; i < fileURLs.count; i++ {
                    do {
                    _ = try data.appendPartWithFileURL(fileURLs[i], name: "images[\(names[i])]", fileName: names[i], mimeType: "image/jpeg")
                    }catch{
                        
                    }
                    // println("was file added properly to the body? \(res) ")
                }
            },
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) in
                //println("Yes thies was a success")
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(response as! NSData, options: .MutableLeaves) as? NSDictionary
                    self.delegate?.success(true, resultsArr: nil, results: json)
                }catch{
                    
                }
                
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
  
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                //println("We got an error here.. \(error.localizedDescription)")
                self.delegate?.success(false, resultsArr: nil, results: nil)
                let alert = UIAlertView(title: "Internet ýok", message: "Ýene bir az wagtdan synanşyp görüň", delegate: self, cancelButtonTitle: "OK")
                alert.show()
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
}