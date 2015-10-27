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
    
    override func viewDidLoad() {
        self.scrollView.contentSize.width = self.view.frame.size.width
        self.scrollView.frame.size.width = self.view.frame.size.width
    }
    
    
}

