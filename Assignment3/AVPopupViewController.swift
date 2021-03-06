//
//  PopupViewController.swift
//  Assignment3
//
//  Created by Brandon Groff on 10/27/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import UIKit

class AVPopupViewController: UIViewController {
    
    var jsonData: NSDictionary!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    @IBOutlet weak var collectionName: UILabel!
    @IBOutlet weak var trackPrice: UILabel!
    @IBOutlet weak var collectionPrice: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.setDataLabels()
        
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
        self.trackName.text = jsonData["trackName"] as? String
        self.artistName.text = jsonData["artistName"] as? String
        self.collectionName.text = jsonData["collectionName"] as? String
        let colPrice = jsonData["collectionPrice"] as! Double
        if (colPrice == 0.0){
            self.collectionPrice.text = "Free"
        } else {
            self.collectionPrice.text = "$\(colPrice)"
        }
        let price = jsonData["trackPrice"] as! Double
        if (price == 0.0){
            self.trackPrice.text = "Free"
        } else {
            self.trackPrice.text = "$\(price)"
        }
        
               
    }
    
    func tap(){
        let label = UILabel(frame: CGRect(x: 0, y: 16, width: self.view.bounds.width, height: 22))
        label.text = "Double tap to go back"
        label.textColor = UIColor.lightGrayColor()
        label.textAlignment = NSTextAlignment.Center
        let font = UIFont(name: "Avenir Light", size: 15)
        label.font = font
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
    
    
}
