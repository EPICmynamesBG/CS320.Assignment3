//
//  DetailViewController.swift
//  Assignment3
//
//  Created by Brandon Groff on 10/4/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate {
    
    var eventDict:Dictionary<String, String>!
    let severityColorDict: Dictionary<String, UIColor> = ["Extreme": UIColor.redColor(), "Severe":UIColor.orangeColor(), "Moderate": UIColor.yellowColor()]
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var effectiveLabel: UILabel!
    @IBOutlet weak var expiresLabel: UILabel!
    @IBOutlet weak var urgencyLabel: UILabel!
    @IBOutlet weak var severityLabel: UILabel!
    @IBOutlet weak var certaintyLabel: UILabel!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.eventDict.isEmpty){
            //error, go back
            self.navigationController?.popViewControllerAnimated(true)
            
        }
        self.navigationItem.title = self.eventDict["event"]
        self.mapView.delegate = self
        
        self.updateLabels()
        
        scrollView.contentSize.width = self.view.frame.size.width - 16
        scrollView.frame.size.width = self.view.frame.size.width - 16
        
        if (self.eventDict["polygon"] != ""){
            self.createDetailedMapView()
        } else {
            self.createGeneralMapView()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
//MARK: Update view label content
    
    private func updateLabels(){
        
        //dateTime formatting
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let effective = self.eventDict["effective"]
        let expires = self.eventDict["expires"]
        let effectiveDate: NSDate? = formatter.dateFromString(effective!)
        let expiresDate: NSDate? = formatter.dateFromString(expires!)
        formatter.dateStyle = NSDateFormatterStyle.FullStyle
        formatter.timeStyle = NSDateFormatterStyle.FullStyle
        let effectiveParsed = formatter.stringFromDate(effectiveDate!)
        let expiresParsed = formatter.stringFromDate(expiresDate!)
        //finished dateTime formatting to human readable text
        
        self.effectiveLabel.text = "Effective from \(effectiveParsed)"
        self.expiresLabel.text = expiresParsed
        
        self.urgencyLabel.text = "Urgency: " + self.eventDict["urgency"]!
        self.severityLabel.text = "Severity: " + self.eventDict["severity"]!
        self.certaintyLabel.text = "Certainty of Occurance: " + self.eventDict["certainty"]!
        
        self.summaryLabel.text = self.eventDict["summary"]
    }
    
//MARK: Custom MapView location zooming/processing
    
    //General used when polygon data is not present
    private func createGeneralMapView(){
        let geocoder: CLGeocoder = CLGeocoder()
        let generalLocArray = self.eventDict["areaDesc"]!.characters.split(";").map(String.init)
        let address = generalLocArray[0] + ", " + self.eventDict["state"]!
        
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks: [CLPlacemark]?, error: NSError?) -> Void in
            if (placemarks?.count != 0 && placemarks != nil ){
                //use first location data found to zoom to area
                let region = self.calculateRegion(placemarks!, spanDelta: 0.5)
                
                //now make updates live
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.mapView.setRegion(region, animated: false)
                })
            }
            if ((error) != nil){
                print("Error finding initial region. Falling back.")
                print(error?.localizedDescription)
                
                //if no location found, resort to full state
                geocoder.geocodeAddressString(self.eventDict["state"]!, completionHandler: { (placemarks2: [CLPlacemark]?, error2: NSError?) -> Void in
                    if (placemarks2?.count != 0 && placemarks2 != nil){
                        let region2 = self.calculateRegion(placemarks2!, spanDelta: 5.5)
                        
                        //now make updates live
                        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                            self.mapView.setRegion(region2, animated: false)
                        })
                    }
                }) //end second geocoder call
            }
        }) //end initial geocoder call
        
    }
    
    private func calculateRegion(placemarks: Array<CLPlacemark>, spanDelta span: Double) -> MKCoordinateRegion{
        let locationCoor = CLLocationCoordinate2D(latitude: (placemarks[0].location?.coordinate.latitude)!, longitude: (placemarks[0].location?.coordinate.longitude)!)
        let coorSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(span), longitudeDelta: CLLocationDegrees(span))
        let region: MKCoordinateRegion = MKCoordinateRegion(center: locationCoor, span: coorSpan)
        return region
    }
    
    //Detailed used when polygon data is present
    private func createDetailedMapView(){
        var coorArray: Array<CLLocationCoordinate2D> = Array<CLLocationCoordinate2D>()
        let locations: String = self.eventDict["polygon"]!
        let stringArray = locations.characters.split(" ").map(String.init)
        
        var maxLat: Double = -360.0; var minLat:Double = 360.0;
        var maxLong: Double = -360.0; var minLong: Double = 360.0;
        // ^ to ensure they always get changed
        
        for (var i:Int = 0; i < stringArray.count; i++){
            let tempLoc = stringArray[i].characters.split(",").map(String.init)
            let latDouble: Double = Double(tempLoc[0])!
            let longDouble = Double(tempLoc[1])!
            
            let lat: CLLocationDegrees = CLLocationDegrees(latDouble)
            let long: CLLocationDegrees = CLLocationDegrees(longDouble)
            coorArray.append(CLLocationCoordinate2D(latitude: lat, longitude: long))
            
            if (latDouble > maxLat){
                maxLat = latDouble
            }
            if (latDouble < minLat){
                minLat = latDouble
            }
            if (longDouble > maxLong){
                maxLong = longDouble
            }
            if (longDouble < minLong){
                minLong = longDouble
            }
            
        }
        // ^ creates an array with the different points recieved from cap:polygon
        // also finds min and max lat and long for use in Deltas below
        
        let centerPoint: CLLocationCoordinate2D = self.calculateMapCenter(coorArray)
        
        let coorSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(abs(maxLat - minLat) * 2.0), longitudeDelta: CLLocationDegrees(abs(maxLong - minLong) * 2.0))
        
        let region:MKCoordinateRegion = MKCoordinateRegion(center: centerPoint, span: coorSpan)
        
        self.mapView.setRegion(region, animated: false)
        
        self.drawMapOverlay(coorArray)
    }
    
    
    private func calculateMapCenter(coorArray:Array<CLLocationCoordinate2D>) -> CLLocationCoordinate2D{
        var latSum: Double = 0.0
        var longSum: Double = 0.0
        for (var i:Int = 0; i < coorArray.count; i++){
            let coordinate = coorArray[i]
            latSum += Double(coordinate.latitude)
            longSum += Double(coordinate.longitude)
        }
        return CLLocationCoordinate2D(latitude: CLLocationDegrees(latSum/Double(coorArray.count)), longitude: CLLocationDegrees(longSum/Double(coorArray.count)))
    }
    
//MARK: Custom map overlay creator
    
    private func drawMapOverlay(coorArray: Array<CLLocationCoordinate2D>){

        let unsafePoints: UnsafeMutablePointer<CLLocationCoordinate2D> = UnsafeMutablePointer<CLLocationCoordinate2D>(coorArray)
        let numPoints = coorArray.count
        
        let polygonOverlay: MKPolygon = MKPolygon.init(coordinates: unsafePoints, count: numPoints)
        self.mapView.addOverlay(polygonOverlay)
    }
    
//MARK: TableViewDelegate function to render map overlays
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if ( overlay.isKindOfClass(MKPolygon)){
            let polyRenderer: MKPolygonRenderer = MKPolygonRenderer(overlay: overlay)
            polyRenderer.lineWidth = CGFloat(1.0)
            polyRenderer.strokeColor = UIColor.blackColor()
            
            var fillColor: UIColor = UIColor.purpleColor()
            if ( severityColorDict[self.eventDict["severity"]!] != nil){
                fillColor = severityColorDict[self.eventDict["severity"]!]!
            }
            polyRenderer.fillColor = fillColor.colorWithAlphaComponent(0.5)
            
            return polyRenderer
        }
        return MKPolygonRenderer(overlay: overlay)
    }
    @IBAction func moreInfoClick(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: self.eventDict["link"]!)!)
    }
}
