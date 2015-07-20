//
//  ImageLoader.swift
//  CacheDemo
//
//  Created by qingjiezhao on 7/20/15.
//  Copyright (c) 2015 qingjiezhao. All rights reserved.
//

import UIKit

class ImageLoader {

    var cache = NSCache()
    
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    func fileExists(urlString : String!) -> Bool {

        let url = NSURL(fileURLWithPath: urlString)
        let req = NSMutableURLRequest(URL: url!)
        req.HTTPMethod = "HEAD"
        req.timeoutInterval = 1.0 // Adjust to your needs
        
        var response : NSURLResponse?
        NSURLConnection.sendSynchronousRequest(req, returningResponse: &response, error: nil)
        if let httpResponse = response as? NSHTTPURLResponse {
            println("123")
            println(httpResponse.expectedContentLength)
        }
        
        println("\((response as? NSHTTPURLResponse)?.statusCode)")
        let code = ((response as? NSHTTPURLResponse)?.statusCode ?? -1)
        var b : Bool = false
        switch code {
        case -1:
            b = false
        case 200:
            b = true
        case 404:
            b = false
        default:
            println(code)
            break
        }
        return b
    }
    
    func isHostConnected(hostAddress : String) -> Bool
    {
        let request = NSMutableURLRequest(URL: NSURL(string: hostAddress.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!)
        request.timeoutInterval = 3
        request.HTTPMethod = "HEAD"
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        var responseCode = -1
        
        let group = dispatch_group_create()
        dispatch_group_enter(group)
        
        session.dataTaskWithRequest(request, completionHandler: {(_, response, _) in
            if let httpResponse = response as? NSHTTPURLResponse {
                responseCode = httpResponse.statusCode
            }
            dispatch_group_leave(group)
        }).resume()
        
        dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
        println(responseCode)
        var b : Bool = false
        switch responseCode {
        case -1:
            //b = false
            println("-1")
        case 200:
            b = true
            println("200")
        case 400:
            b = true
            println("400")
        case 404:
            //b = false
            println("404, not found")
        default:
            println("default \(responseCode)" )
            break
        }
        return b
    }
    
    
    func imageForUrl(urlString:String, completionHandler:(image:UIImage?,url:String) ->()){
     
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {() in
            var data:NSData? = self.cache.objectForKey(urlString) as? NSData
            
            if let goodData = data{
                let image = UIImage(data: goodData)
                dispatch_async(dispatch_get_main_queue(), {() in
                    completionHandler(image: image, url: urlString)
                })
                return
            }
            
            var downloadTask : NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!,completionHandler:{(data:NSData!,response:NSURLResponse!,error:NSError!) -> Void in
                if error != nil {
                    completionHandler(image: nil, url: urlString)
                    return
                }
                
                if data != nil {
                    let image = UIImage(data: data)
                    self.cache.setObject(data, forKey: urlString)
                    dispatch_async(dispatch_get_main_queue(), {() in
                        completionHandler(image: image, url: urlString)
                    })
                    return
                }
            })
            downloadTask.resume()
        
        })
    }
}
