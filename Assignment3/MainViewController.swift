//
//  ViewController.swift
//  Assignment3
//
//  Created by Brandon Groff on 10/27/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, iTunesRequestorDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var jsonData: NSDictionary!
    var requestor: iTunesRequestor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestor = iTunesRequestor()
        self.requestor.delegate = self
    }
    
    //------------ TABLE VIEW -----------

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        // below needs testing
        // if(type = Audio or Video) -> AVPopupViewController
        let popupVC = AVPopupViewController()
        let nav = UINavigationController(rootViewController: popupVC)
        popupVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        let popover = nav.popoverPresentationController
        popupVC.preferredContentSize = CGSizeMake(self.view.bounds.width - 20, self.view.bounds.height / 2)
        popover?.delegate = self
        popover?.sourceView = self.view
        popover!.sourceRect = CGRectMake(100,100,0,0)
        
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //code
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:CustomTableCell = self.tableView.dequeueReusableCellWithIdentifier("customTableCell") as! CustomTableCell
        
        
        return cell
    }
    
    //------------- END TABLE VIEW------------
    
    //---------- SEARCH BAR ---------------
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        print("Searching \(self.searchBar.text!)")
        self.requestor.searchByTerm(self.searchBar.text!)
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        print("Editing")
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.spinner.startAnimating()
        print("Done editing")
    }
    
    // ------------ END SEARCH BAR ----------
    
    // ------------ ITUNES REQUESTOR ---------
    
    func iTunesRequestCompleted() {
        self.jsonData = self.requestor.jsonData
        self.spinner.stopAnimating()
        
        print(jsonData)
        //self.tableView.reloadData() <-- uncomment to get table to refresh
    }
    
    //-------------- END ITUNES REQUESTOR ---------
}

