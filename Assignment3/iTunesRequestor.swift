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
    optional func iTunesRequestCompleted(jsonData: NSArray)
    optional func imageRequestCompleted(image: UIImage)
    optional func cellImageRequestCompleted(index: Int, withImage image: UIImage)
}

class iTunesRequestor {
    
    var delegate:iTunesRequestorDelegate?
    var makingRequest: Bool!
    var requestURLBase:String! = ""
    var limit: String! = ""
    
    init(){
        self.requestURLBase = "https://itunes.apple.com/search?term="
        self.limit = "&limit=25"
    }
    
    func searchByTerm(term:String){
        self.makingRequest = true
        let editedTerm = term.stringByReplacingOccurrencesOfString(" ", withString: "+")
        
        let stringURL = self.requestURLBase + editedTerm +  self.limit
        let url: NSURL = NSURL(string: stringURL)!
        self.urlRequest(url)
    }
    
    func searchByTermAndEntity(term: String, entityType entity: String){
        self.makingRequest = true
        let editedTerm = term.stringByReplacingOccurrencesOfString(" ", withString: "+")
        var entityString: String!
        
        if (entity == "music"){
            entityString = "&entity=musicArtist&entity=song&entity=album&entity=musicTrack"
        } else if (entity == "movie"){
            entityString = "&entity=movieArtist&entity=movie"
        } else if (entity == "software"){
            entityString = "&entity=software"
        } else {
            entityString = "&entity=movie&entity=album&entity=allArtist"
            //generic search all
        }
        
        let stringURL = self.requestURLBase + editedTerm + entityString + self.limit
        let url: NSURL = NSURL(string: stringURL)!
        self.urlRequest(url)
    }
    
    private func urlRequest(url: NSURL){
        let session: NSURLSession = NSURLSession.sharedSession()
        var json: NSArray!
        let dataTask: NSURLSessionDataTask = session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (data != nil && error == nil){
                json = self.parseJSON(data)
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.makingRequest = false
                self.delegate?.iTunesRequestCompleted!(json)
            })
            
        }
        dataTask.resume()
    }
    
    func parseJSON(data: NSData?) -> NSArray{
        var parsedData:NSDictionary!
        var resultArray: NSArray!
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
        } catch {
            print("Error parsing JSON")
        }
        resultArray = parsedData["results"] as! NSArray
        return resultArray
    }
    
    //DEPRACATED
    func getIconImage(url: String) -> UIImage{
        let data:NSData = NSData(contentsOfURL: NSURL(string: url)!)!
        let icon = UIImage(data: data)!
        return icon
    }
    
    func getImageInBackground(url: String) {
        var fetchedImage: UIImage!
        let session: NSURLSession = NSURLSession.sharedSession()
        let dataTask: NSURLSessionDataTask = session.dataTaskWithURL(NSURL(string: url)!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (data != nil && error == nil){
                fetchedImage = UIImage(data: data!)!
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.makingRequest = false
                self.delegate?.imageRequestCompleted!(fetchedImage)
            })
            
        }
        dataTask.resume()
    }
    
    func getCellImageInBackground(url: String, atIndex index: Int) {
        let thisURL = NSURL(string: url)!
        var fetchedImage: UIImage!
        let session: NSURLSession = NSURLSession.sharedSession()
        let dataTask: NSURLSessionDataTask = session.dataTaskWithURL(thisURL) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if (data != nil && error == nil){
                fetchedImage = UIImage(data: data!)!
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.makingRequest = false
                self.delegate?.cellImageRequestCompleted!(index, withImage: fetchedImage)
            })
            
        }
        dataTask.resume()
    }
    
}