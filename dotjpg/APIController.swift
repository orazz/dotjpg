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

        })
    }
    
    func imageUploader(params:Dictionary<String, AnyObject>, fileURLs: [NSURL], names: [String]){
        var parametrs = params
        parametrs["session_id"] = token
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        manager.POST("", parameters: parametrs,
            constructingBodyWithBlock: { (data: AFMultipartFormData!) in
                for var i = 0; i < fileURLs.count; i++ {
                    //var res = data.appendPartWithFileURL(fileURLs[i], name: "images", error: nil)
                    
                    var res = data.appendPartWithFileURL(fileURLs[i], name: "images[\(names[i])]", fileName: names[i], mimeType: "image/jpeg", error: nil)
                    
                    // println("was file added properly to the body? \(res) ")
                }
            },
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) in
                //println("Yes thies was a success")
                
                    var json = NSJSONSerialization.JSONObjectWithData(response as! NSData, options: .MutableLeaves, error: &self.err) as? NSDictionary
                    println(json)
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false

                
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) in
                //println("We got an error here.. \(error.localizedDescription)")

                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }
    
    /**
    *  Function to upload image & data using POST request
    *
    *  @param image:NSData       image data of type NSData
    *  @param fieldName:String   field name for uploading image
    *  @param data:RequestData?  optional value of type Dictionary<String,AnyObject>
    *
    *  @return self instance to support function chaining
    *
    public func data(image:[NSData], fieldName:String, data:RequestData?) -> SRWebClient {
        
        let uniqueId = NSProcessInfo.processInfo().globallyUniqueString
        
        var postBody:NSMutableData = NSMutableData()
        var postData:String = String()
        var boundary:String = "------WebKitFormBoundary\(uniqueId)"
        
        self.urlRequest?.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField:"Content-Type")
        
        if(data != nil && data!.count > 0) {
            postData += "--\(boundary)\r\n"
            for (key, value : AnyObject) in data! {
                if let value = value as? String {
                    postData += "--\(boundary)\r\n"
                    postData += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                    postData += "\(value)\r\n"
                }
            }
        }
        
        for i in image{
            postData += "--\(boundary)\r\n"
            postData += "Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(Int64(NSDate().timeIntervalSince1970*1000)).jpg\"\r\n"
            postData += "Content-Type: image/jpeg\r\n\r\n"
            postBody.appendData(postData.dataUsingEncoding(NSUTF8StringEncoding)!)
            postBody.appendData(i)
            postData = String()
            postData += "\r\n"
            postData += "\r\n--\(boundary)--\r\n"
            postBody.appendData(postData.dataUsingEncoding(NSUTF8StringEncoding)!)
            
        }
        
        
        self.urlRequest!.HTTPBody = NSData(data: postBody)
        
        return self
    }*/
}