//
//  ViewController.swift
//  Assignment3
//
//  Created by Brandon Groff on 10/1/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    private let states = ["Alabama":"AL", "Alaska":"AK", "Arizona":"AZ",
    "Arkansas": "AR", "California":"CA", "Colorado":"CO", "Connecticut":"CT",
    "Delaware":"DE", "District of Columbia":"DC", "Florida":"FL", "Georgia":"GA",
    "Hawaii":"HI", "Idaho":"ID", "Illinois": "IL", "Indiana":"IN",
    "Iowa":"IA","Kansas":"KS", "Kentucky":"KY","Louisiana":"LA",
    "Maine":"ME", "Maryland":"MD","Massachusetts":"MA", "Michigan":"MI",
    "Minnesota":"MN", "Mississippi": "MS", "Missouri":"MO", "Montana": "MT",
    "Nebraska":"NE", "Neveda":"NV", "New Hampshire":"NH", "New Jersey":"NJ",
    "New Mexico":"NM", "New York":"NY", "North Carolina": "NC", "North Dakota":"ND",
    "Ohio":"OH", "Oklahoma":"OK", "Oregon":"OR", "Pennsylvania":"PA",
    "Rhode Island":"RI", "South Carolina":"SC","South Dakota":"SD", "Tennessee":"TN",
    "Texas":"TX", "Utah":"UT", "Vermont":"VT", "Virginia":"VA",
        "Washington":"WA", "West Virginia":"WV", "Wisconsin":"WI", "Wyoming":"WY"]
    
    private let baseURLStart = "http://alerts.weather.gov/cap/"
    private let baseURLEnd = ".php?x=0"
    
    private var stateArray:Array<String> = Array<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        stateArray = Array(self.states.keys)
        stateArray = stateArray.sort()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.states.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("stateCell")!
        cell.textLabel!.text = stateArray[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let state:String = (sender?.textLabel!!.text)!
        
        if (segue.identifier == "stateToEvent"){
            let svc = segue.destinationViewController as! EventTableViewController
            svc.requestURL = baseURLStart+self.states[state]!+baseURLEnd
            svc.navTitle = state
            
        }
    }
}


