//
//  ViewController.swift
//  Assignment3
//
//  Created by Brandon Groff on 10/1/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import UIKit

class EventTableViewController: UITableViewController {
    
    var requestURL:String!
    var navTitle:String!
    var parsedData: Array<Dictionary<String, String>>!
    var xmlParser: DataParser!
    let severityColorDict: Dictionary<String, UIColor> = ["Extreme": UIColor.redColor(), "Severe":UIColor.orangeColor(), "Moderate": UIColor.yellowColor()]
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.spinner.startAnimating()
        self.parsedData = Array<Dictionary<String, String>>()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.title = navTitle
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //prevents crashing caused by selecting a state, going back, and reselecting it
        if (self.tableView(self.tableView, numberOfRowsInSection: 0) == 0){
            loadXMLData(NSURL(string: requestURL)!)
        }
    }
    
//MARK: TableViewDelegate functions
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.parsedData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("eventCell")!
        
        cell.textLabel?.text = self.parsedData[indexPath.row]["event"]
        cell.tag = Int(self.parsedData[indexPath.row]["entry"]!)!
        
        let expiration = self.parsedData[indexPath.row]["expires"]!
        if (!expiration.isEmpty){
            //dateTime formatting
            let formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let expiresDate: NSDate? = formatter.dateFromString(expiration)
            formatter.dateStyle = NSDateFormatterStyle.MediumStyle
            formatter.timeStyle = NSDateFormatterStyle.MediumStyle
            let expiresParsed = formatter.stringFromDate(expiresDate!)
            //finished dateTime formatting to human readable text
            
            cell.detailTextLabel?.text = "Ends \(expiresParsed)"
        }
        
        if (self.severityColorDict[self.parsedData[indexPath.row]["severity"]!] != nil){
            cell.backgroundColor = self.severityColorDict[self.parsedData[indexPath.row]["severity"]!]
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor.darkGrayColor()
        }
        
        return cell
    }
    
//MARK: XML Data processing
    
    private func loadXMLData(url:NSURL){
        
        let session: NSURLSession = NSURLSession.sharedSession()
        let dataTask: NSURLSessionDataTask = session.dataTaskWithURL(url) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            self.parseXML(data!)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.updateTable()
            })
        }
        dataTask.resume()
        
    }
    
    private func parseXML(data:NSData){
        self.xmlParser = DataParser(data: data)
        self.parsedData = xmlParser.parsedArray
    }

//MARK: Post-XML Processing tableView update
    
    private func updateTable(){
        var indexes = Array<NSIndexPath>()
        for (var i = 0 ; i < self.parsedData.count; i++){
            indexes.append(NSIndexPath(forRow: i, inSection: 0))
        }
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.endUpdates()
        self.spinner.stopAnimating()
    }
    
//MARK: Segue - pass data to next view
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (sender is UITableViewCell){
            let theSender = sender as! UITableViewCell
            
            if (segue.identifier == "eventToDetail"){
                let svc = segue.destinationViewController as! DetailViewController
                let index:Int = theSender.tag
                svc.eventDict = self.parsedData[index]
                svc.eventDict.updateValue(self.navigationItem.title!, forKey: "state")
            }
        }
        
    }
    
}

