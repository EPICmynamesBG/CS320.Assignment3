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
    @IBOutlet weak var searchTypeController: UISegmentedControl!
    var responseData: NSArray!
    var requestor: iTunesRequestor!
    let searchTypeArray = ["all","music","movie","software"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.modalPresentationStyle = UIModalPresentationStyle.PageSheet
        self.navigationController?.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        requestor = iTunesRequestor()
        self.requestor.delegate = self
        self.searchTypeController.addTarget(self, action: "changeSearchType", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    func changeSearchType(){
        //only runs when a search has already been made and
        // the type changes, thus updating to new filter
        if (self.tableView.numberOfRowsInSection(0) != 0){
            self.initiateSearch()
        }
    }
    
    //------------ TABLE VIEW -----------

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let dict = self.responseData[indexPath.row] as! NSDictionary
        let type = dict["kind"] as! String
        var popupVC: UIViewController!
        if (type == "song" || type == "artist"){
            popupVC = self.storyboard?.instantiateViewControllerWithIdentifier("AVPopupViewController")
        } else if (type == "software-package"){
            popupVC = self.storyboard?.instantiateViewControllerWithIdentifier("SoftwarePopupViewController")
        } else if (type == "feature-movie"){
            popupVC = self.storyboard?.instantiateViewControllerWithIdentifier("MoviePopupViewController")
        } else {
            return
        }
        
        UIView.animateWithDuration(0.75) { () -> Void in
            UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
            self.navigationController?.pushViewController(popupVC, animated: false)
            UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: (self.navigationController?.view)!, cache: false)
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //do nothing
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.responseData == nil){
            return 0
        }
        print(self.responseData.count)
        return self.responseData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:CustomTableCell = self.tableView.dequeueReusableCellWithIdentifier("customTableCell") as! CustomTableCell
        let dict = self.responseData[indexPath.row] as! NSDictionary
        cell = self.setCellData(cell, withData: dict)
        
        return cell
    }
    
    private func setCellData(cell: CustomTableCell, withData dict: NSDictionary) -> CustomTableCell{
        let type = dict["kind"] as! String
        if (type == "song" || type == "artist"){
            cell.title.text = dict["trackName"] as? String
            cell.subtitle.text = dict["collectionName"] as? String
            cell.iconImage.image = self.requestor.getIconImage(dict["artworkUrl100"] as! String)
        } else if (type == "software"){
            cell.title.text = dict["artistName"] as? String
            let price = dict["price"] as! Double
            if (price == 0.0){
                cell.subtitle.text = "Free"
            } else {
                cell.subtitle.text = "$\(price)"
            }
            
            cell.iconImage.image = self.requestor.getIconImage(dict["artworkUrl100"] as! String)
        } else if (type == "feature-movie"){
            cell.title.text = dict["trackName"] as? String
            cell.subtitle.text = "Rated " + (dict["contentAdvisoryRating"] as? String)!
            cell.iconImage.image = self.requestor.getIconImage(dict["artworkUrl100"] as! String)
        } else {
            cell.title.text = "Useless data"
            cell.subtitle.text = "Useless data"
            cell.iconImage.hidden = true
        }
        
        return cell
    }
    
    //------------- END TABLE VIEW------------
    
    //---------- SEARCH BAR ---------------
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        self.initiateSearch()
    }
    
    private func initiateSearch(){
        self.responseData = nil
        self.tableView.reloadData()
        self.spinner.startAnimating()
        print("Searching \(self.searchBar.text!)")
        if (self.searchTypeController.selectedSegmentIndex == 0){
            self.requestor.searchByTerm(self.searchBar.text!)
        } else {
            let entity = self.searchTypeArray[self.searchTypeController.selectedSegmentIndex]
            self.requestor.searchByTermAndEntity(self.searchBar.text!, entityType: entity)
        }
    }
    
    // ------------ END SEARCH BAR ----------
    
    // ------------ ITUNES REQUESTOR ---------
    
    func iTunesRequestCompleted() {
        self.responseData = self.requestor.jsonData
        self.spinner.stopAnimating()
        print(responseData)
        self.tableView.reloadData()
    }
    
    //-------------- END ITUNES REQUESTOR ---------
}

