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
    @IBOutlet weak var genres: UILabel!
    @IBOutlet weak var longDescription: UILabel!
    @IBOutlet weak var supportedDevices: UILabel!
    @IBOutlet weak var appIcon: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var screenshotArray : Array<UIImage>!
    var numScreenshots: Int!
    var scaleRatio: CGFloat!
    var imgWidth: CGFloat!
    
    var requestor: iTunesRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.requestor = iTunesRequestor()
        self.requestor.delegate = self
        
        self.setDataLabels()
        self.screenshotArray = Array<UIImage>()
        
        self.scrollView.contentSize.width = self.view.frame.size.width
        self.scrollView.frame.size.width = self.view.frame.size.width
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap")
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap")
        tap.numberOfTapsRequired = 1
        tap2.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(tap2)
    }
    
    private func setDataLabels(){
        //TODO
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
    
    // ------ UICollectionView Delegate
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("screenshotCell", forIndexPath: indexPath) as! CustomCollectionCell
        if (self.screenshotArray.count != 0){
            let screenshot = self.screenshotArray[indexPath.row]
            cell.image.image = screenshot
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let imagesArray = self.jsonData["screenshotUrls"] as! NSArray
        return imagesArray.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let calculatedCollectionHeight = self.collectionView.frame.height - 2
            if (self.scaleRatio != nil){
                return CGSize(width: self.imgWidth * self.scaleRatio, height: calculatedCollectionHeight)
            }
            
            return CGSize(width: 225, height: calculatedCollectionHeight)
    }
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    
    
    // ---------- iTunes Requestor
    
    func imageRequestCompleted(image: UIImage) {
        //set images
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

