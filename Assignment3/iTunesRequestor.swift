//
//  iTunesRequestor.swift
//  Assignment3
//
//  Created by Brandon Groff on 10/27/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import Foundation
import UIKit

@objc protocol iTunesRequestorDelegate {
    optional func iTunesRequestCompleted()
}

class iTunesRequestor {
    
    var delegate:iTunesRequestorDelegate?
    var makingRequest: Bool!
    var requestURLBase:String! = ""
    var jsonData: NSDictionary!
    
    init(){
        self.requestURLBase = "https://itunes.apple.com/search?term="
    }
    
    func searchByTerm(term:String){
        self.makingRequest = true
        let editedTerm = term.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        let stringURL = self.requestURLBase + editedTerm
        let url: NSURL = NSURL(string: stringURL)!
        let session: NSURLSession = NSURLSession.sharedSession()
        let dataTask: NSURLSessionDataTask = session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (data != nil && error == nil){
                self.jsonData = self.parseJSON(data)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.makingRequest = false
                self.delegate?.iTunesRequestCompleted!()
            })
            
        }
        dataTask.resume()
    }
    
    func parseJSON(data: NSData?) -> NSDictionary{
        var parsedData:NSDictionary!
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        } catch {
            print("Error parsing JSON")
        }
        return parsedData
    }
    
    func getIconImage(url: String) -> UIImage{
        let data:NSData = NSData(contentsOfURL: NSURL(string: url)!)!
        let icon = UIImage(data: data)!
        return icon
    }
}