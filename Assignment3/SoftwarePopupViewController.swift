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
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var longDescription: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var supportedDevices: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    var requestor: iTunesRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.requestor = iTunesRequestor()
        self.requestor.delegate = self
        self.setDataLabels()
        
        self.scrollView.contentSize.width = self.view.frame.size.width - 16
        self.scrollView.frame.size.width = self.view.frame.size.width
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap")
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap")
        tap.numberOfTapsRequired = 1
        tap2.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(tap2)
        
    }
    
    func setDataLabels(){
        self.artistName.text = self.jsonData["artistName"] as? String
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
        if (imagesArray.count >= 2){
            self.requestor.getImageInBackground(imagesArray[0] as! String)
            self.requestor.getImageInBackground(imagesArray[1] as! String)
            
        } else {
            self.imageView1.hidden = true
            self.imageView2.hidden = true
        }
        
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
    
    func imageRequestCompleted(image: UIImage) {
        if (self.imageView1.image == nil){
            self.imageView1.image = image
        } else {
            self.imageView2.image = image
        }
    }
}

