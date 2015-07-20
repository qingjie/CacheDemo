//
//  ViewController.swift
//  CacheDemo
//
//  Created by qingjiezhao on 7/20/15.
//  Copyright (c) 2015 qingjiezhao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //this file is existed
    let urlString = "http://www.natcom.org/uploadedImages/More_Scholarly_Resources/Doctoral_Program_Resource_Guide/Syracuse%20Logo.jpg"
    
    //this file is not existed!
    //let urlString = "http://upload.wikimedia.org/wikipedia/en/4/43/Apple_Swift_Logo.png"

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       
        
        let b = ImageLoader.sharedLoader.isHostConnected(urlString)
        if b {
            method1()
        }else{
            println("File is not existed!")
        }
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func method1(){
        ImageLoader.sharedLoader.imageForUrl(urlString, completionHandler: {(image: UIImage?,url:String) in
            self.imageView.image = image!
        })

    }
    
    func method2(){
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            var myImage =  UIImage(data: NSData(contentsOfURL: NSURL(string: self.urlString)!)!)
             self.imageView.image = myImage!
        })
    }
    
    
    


}

