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
        
        let tapOutsideSearch: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tap")
        self.view.addGestureRecognizer(tapOutsideSearch)
    }
    
    func tap(){
        self.searchBar.resignFirstResponder()
    }
    
    func changeSearchType(){
        //only runs when a search has already been made and
        // the type changes, thus updating to new filter
        if (self.searchBar.text?.isEmpty == false){
            self.initiateSearch()
            self.searchBar.resignFirstResponder()
        }
    }
    
    //------------ TABLE VIEW -----------

    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        let dict = self.responseData[indexPath.row] as! NSDictionary
        let type = dict["kind"] as! String
        if (type == "song" || type == "artist"){
            let popupVC: AVPopupViewController = self.storyboard?.instantiateViewControllerWithIdentifier("AVPopupViewController") as! AVPopupViewController
            popupVC.jsonData = self.responseData[indexPath.row] as! NSDictionary
            UIView.animateWithDuration(0.75) { () -> Void in
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
                self.navigationController?.pushViewController(popupVC, animated: false)
                UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: (self.navigationController?.view)!, cache: false)
            }
        } else if (type == "software"){
            let popupVC = self.storyboard?.instantiateViewControllerWithIdentifier("SoftwarePopupViewController") as! SoftwarePopupViewController
            popupVC.jsonData = self.responseData[indexPath.row] as! NSDictionary
            UIView.animateWithDuration(0.75) { () -> Void in
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
                self.navigationController?.pushViewController(popupVC, animated: false)
                UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: (self.navigationController?.view)!, cache: false)
            }
        } else if (type == "feature-movie"){
            let popupVC = self.storyboard?.instantiateViewControllerWithIdentifier("MoviePopupViewController") as! MoviePopupViewController
            popupVC.jsonData = self.responseData[indexPath.row] as! NSDictionary
            UIView.animateWithDuration(0.75) { () -> Void in
                UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
                self.navigationController?.pushViewController(popupVC, animated: false)
                UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: (self.navigationController?.view)!, cache: false)
            }
        } else {
            return
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //do nothing when cell is selected
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.responseData == nil){
            return 0
        }
        return self.responseData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:CustomTableCell = self.tableView.dequeueReusableCellWithIdentifier("customTableCell") as! CustomTableCell
        let dict = self.responseData[indexPath.row] as! NSDictionary
        cell = self.setCellData(cell,atIndex: indexPath.row, withData: dict)
        
        return cell
    }
    
    private func setCellData(cell: CustomTableCell, atIndex index:Int, withData dict: NSDictionary) -> CustomTableCell{
        if (dict["kind"] == nil){
            cell.title.text = "Useless data"
            cell.subtitle.text = "Useless data"
            cell.iconImage.hidden = true
            return cell
        }
        let type = dict["kind"] as! String
        if (type == "song" || type == "artist"){
            cell.title.text = dict["trackName"] as? String
            cell.subtitle.text = dict["collectionName"] as? String
        } else if (type == "software"){
            cell.title.text = dict["artistName"] as? String
            let price = dict["price"] as! Double
            if (price == 0.0){
                cell.subtitle.text = "Free"
            } else {
                cell.subtitle.text = "$\(price)"
            }
        } else if (type == "feature-movie"){
            cell.title.text = dict["trackName"] as? String
            cell.subtitle.text = "Rated " + (dict["contentAdvisoryRating"] as? String)!
            
        } else {
            cell.title.text = "Useless data"
            cell.subtitle.text = "Useless data"
            cell.iconImage.hidden = true
        }
        
        self.requestor.getCellImageInBackground(dict["artworkUrl100"] as! String, atIndex: index)
        
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
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        if (self.searchTypeController.selectedSegmentIndex == 0){
            self.requestor.searchByTerm(self.searchBar.text!)
        } else {
            let entity = self.searchTypeArray[self.searchTypeController.selectedSegmentIndex]
            self.requestor.searchByTermAndEntity(self.searchBar.text!, entityType: entity)
        }
    }
    
    // ------------ END SEARCH BAR ----------
    
    // ------------ ITUNES REQUESTOR ---------
    
    func iTunesRequestCompleted(jsonData: NSArray) {
        self.responseData = jsonData
        self.spinner.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.tableView.reloadData()
    }
    
    func cellImageRequestCompleted(index: Int, withImage image: UIImage) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        var cell: CustomTableCell!
        if (self.tableView.cellForRowAtIndexPath(indexPath) != nil){
            cell = self.tableView.cellForRowAtIndexPath(indexPath) as! CustomTableCell
        }
        if (cell != nil){
            if (image.isEqual(nil)){
                cell.iconImage.hidden = true
            } else {
                cell.iconImage.image = image
            }
        } else {
            print("Cell at index \(index) is returning nil")
            let alert = UIAlertController(title: "Cell = nil", message: "Cell at index \(index) is returning nil", preferredStyle: UIAlertControllerStyle.Alert)
            let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (action:UIAlertAction) -> Void in
                self.tableView.reloadData()
            }
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    func noNetworkConnection() {
        self.spinner.stopAnimating()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        let alert = UIAlertController(title: "No Internet Connection", message: "No Internet Connection Found", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (action:UIAlertAction) -> Void in
            //do nothing
        }
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    //-------------- END ITUNES REQUESTOR ---------
}

