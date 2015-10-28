//
//  MoviePopupViewController.swift
//  Assignment3
//
//  Created by Brandon Groff on 10/27/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import UIKit

class MoviePopupViewController: UIViewController {
    
    var jsonData: NSDictionary!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var trackPrice: UILabel!
    @IBOutlet weak var genre: UILabel!
    @IBOutlet weak var longDescription: UILabel!
    
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.scrollView.contentSize.width = self.view.frame.size.width
        self.scrollView.frame.size.width = self.view.frame.size.width
    
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap")
        let tap2: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap")
        tap.numberOfTapsRequired = 1
        tap2.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(tap)
        self.view.addGestureRecognizer(tap2)
    }
    
    func tap(){
        let label = UILabel(frame: CGRect(x: 0, y: self.view.bounds.height - 17, width: self.view.bounds.width, height: 17))
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
    
    
}

