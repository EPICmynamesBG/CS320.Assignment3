//
//  SoftwarePopupViewController.swift
//  Assignment3
//
//  Created by Brandon Groff on 10/27/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import UIKit

class SoftwarePopupViewController: UIViewController, iTunesRequestorDelegate {
    
    var jsonData: NSDictionary!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var screenshotScrollView: UIScrollView!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var longDescription: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var supportedDevices: UILabel!
    @IBOutlet weak var appIcon: UIImageView!
    
    var requestor: iTunesRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.requestor = iTunesRequestor()
        self.requestor.delegate = self
        self.setDataLabels()
        
        self.scrollView.contentSize.width = self.view.frame.size.width - 16
        self.scrollView.frame.size.width = self.view.frame.size.width
        
        self.screenshotScrollView.contentSize.height = 400
        self.scrollView.frame.size.height = 400
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap")
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap")
        tap.numberOfTapsRequired = 1
        tap2.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(tap2)
        
    }
    
    func setDataLabels(){
        let developers: String! = self.jsonData["artistName"] as! String
        let app: String! = self.jsonData["trackName"] as! String
        self.artistName.text = "\(app)\nby \(developers)"
        
        let iconUrl = self.jsonData["artworkUrl100"] as! String
        self.requestor.getImageInBackground(iconUrl, withTag: self.appIcon.tag)
        
        var supDevices = ""
        let devicesArray = self.jsonData["supportedDevices"] as! NSArray
        for (var i = 0; i < devicesArray.count ; i++){
            if (i != devicesArray.count - 1){
                supDevices = supDevices + (devicesArray[i] as! String) + ", "
            } else {
                supDevices = supDevices + (devicesArray[i] as! String)
            }
        }
        self.supportedDevices.text = supDevices
        self.longDescription.text = self.jsonData["description"] as? String
        
        var genres = ""
        let genreArray = self.jsonData["genres"] as! NSArray
        for (var i = 0; i < genreArray.count ; i++){
            if (i != genreArray.count - 1){
                genres = genres + (genreArray[i] as! String) + ", "
            } else {
                genres = genres + (genreArray[i] as! String)
            }
        }
        self.genre.text = genres
        let imagesArray = self.jsonData["screenshotUrls"] as! NSArray
        for (var i = 0; i < imagesArray.count; i++) {
            let imageString = imagesArray[i] as! String
            requestor.getImageInBackground(imageString, withTag: i + 2)
        }
        
    }
    
    private func createImageViewWithImage(image: UIImage, withTag tag:Int){
        var imageView = UIImageView(image: image)
        let ratio: CGFloat = self.screenshotScrollView.frame.size.height / image.size.height
        imageView.frame.size.height = self.screenshotScrollView.frame.size.height
        imageView.frame.size.width = image.size.width * ratio
        
        imageView.tag = tag
        imageView.hidden = true
        self.screenshotScrollView.addSubview(imageView)
        
        if (self.screenshotScrollView.subviews.count == 0){
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.LeadingMargin, relatedBy: NSLayoutRelation.Equal, toItem: self.screenshotScrollView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 8.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.TopMargin, relatedBy: NSLayoutRelation.Equal, toItem: self.screenshotScrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 8.0))
        } else {
            var subviews = self.screenshotScrollView.subviews
            var highestTag: Int = 0
            var highestTagIndex: Int = 0
            
            for (var i = 0; i < subviews.count; i++){
                let iView: UIImageView? = subviews[i] as? UIImageView
                if (iView != nil){
                    if (iView!.tag > highestTag){
                        highestTag = (iView?.tag)!
                        highestTagIndex = i
                    }
                }
            }
            let rightMostView: UIImageView = subviews[highestTagIndex] as! UIImageView
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.LeadingMargin, relatedBy: NSLayoutRelation.Equal, toItem: rightMostView, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: 8.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.TopMargin, relatedBy: NSLayoutRelation.Equal, toItem: self.screenshotScrollView, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 8.0))
            rightMostView.removeConstraint(NSLayoutConstraint(item: rightMostView, attribute: NSLayoutAttribute.RightMargin, relatedBy: NSLayoutRelation.Equal, toItem: self.screenshotScrollView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 8.0))
            imageView.addConstraint(NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.RightMargin, relatedBy: NSLayoutRelation.Equal, toItem: self.screenshotScrollView, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 8.0))
        }
        imageView.hidden = false
    }
    
    func tap(){
        let label = UILabel(frame: CGRect(x: 0, y: 16, width: self.view.bounds.width, height: 17))
        label.text = "Double tap to go back"
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Center
        self.view.addSubview(label)
    }
    
    func doubleTap(){
        if (self.navigationController == nil){
            print("No nav controller")
        }
        UIView.animateWithDuration(0.75) { () -> Void in
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromLeft, forView: (self.navigationController?.view)!, cache: false)
        }
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    func imageRequestCompleted(image: UIImage, withTag tag: Int) {
        if (self.appIcon.tag == tag){
            self.appIcon.image = image
        } else { //tag >=2
            createImageViewWithImage(image, withTag: tag)
        }
        
    }
    
    func noNetworkConnection() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        let alert = UIAlertController(title: "No Internet Connection", message: "No Internet Connection Found", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (action:UIAlertAction) -> Void in
            //do nothing
        }
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

