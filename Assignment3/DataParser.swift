//
//  XMLParser.swift
//  Assignment3
//
//  Created by Brandon Groff on 10/1/15.
//  Copyright © 2015 Brandon Groff. All rights reserved.
//

import Foundation

class DataParser: NSObject, NSXMLParserDelegate {
    
    private let parser:NSXMLParser!
    private var entryNumber: Int
    private var entryFound: Bool!
    private var eventFound: Bool!
    private var summaryFound: Bool!
    private var effectiveFound: Bool!
    private var expiresFound: Bool!
    private var urgencyFound: Bool!
    private var severityFound: Bool!
    private var certaintyFound: Bool!
    private var linkFound: Bool!
    private var polygonFound: Bool!
    private var areaDescFound: Bool!
    var parsedArray: Array<Dictionary<String, String>>
    private var tempDict: Dictionary<String, String> = ["entry":"",
        "event": "",
        "summary":"",
        "effective": "",
        "expires":"",
        "urgency":"",
        "severity":"",
        "certainty":"",
        "link":"",
        "polygon":"",
        "areaDesc":""]
    
    init (data:NSData) {
        self.parser = NSXMLParser(data: data)
        self.entryNumber = 0
        self.entryFound = false
        self.eventFound = false
        self.summaryFound = false
        self.effectiveFound = false
        self.expiresFound = false
        self.urgencyFound = false
        self.severityFound = false
        self.certaintyFound = false
        self.linkFound = false
        self.polygonFound = false
        self.areaDescFound = false
        self.parsedArray = []
        
        super.init()
        self.parser.delegate = self
        parser.parse()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if (elementName == "entry"){
            self.entryFound = true
        }
        if (elementName == "cap:event"){
            self.eventFound = true
        }
        if (elementName == "summary"){
            self.summaryFound = true
        }
        if (elementName == "cap:effective"){
            self.effectiveFound = true
        }
        if (elementName == "cap:expires"){
            self.expiresFound = true
        }
        if (elementName == "cap:urgency"){
            self.urgencyFound = true
        }
        if (elementName == "cap:severity"){
            self.severityFound = true
        }
        if (elementName == "cap:certainty"){
            self.certaintyFound = true
        }
        if (elementName == "id"){
            self.linkFound = true
        }
        if (elementName == "cap:polygon"){
            self.polygonFound = true
        }
        if (elementName == "cap:areaDesc"){
            self.areaDescFound = true
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        
        if (entryFound!){
            self.tempDict.updateValue(self.entryNumber.description, forKey: "entry")
            
            if (eventFound!){
                self.tempDict.updateValue(string, forKey: "event")
            }
            if (summaryFound!){
                self.tempDict.updateValue(string, forKey: "summary")
            }
            if (effectiveFound!){
                self.tempDict.updateValue(string, forKey: "effective")
            }
            if (expiresFound!){
                self.tempDict.updateValue(string, forKey: "expires")
            }
            if (urgencyFound!){
                self.tempDict.updateValue(string, forKey: "urgency")
            }
            if (severityFound!){
                self.tempDict.updateValue(string, forKey: "severity")
            }
            if (certaintyFound!){
                self.tempDict.updateValue(string, forKey: "certainty")
            }
            if (linkFound!){
                self.tempDict.updateValue(string, forKey: "link")
            }
            if (polygonFound!){
                self.tempDict.updateValue(string, forKey: "polygon")
            }
            if (areaDescFound!){
                self.tempDict.updateValue(string, forKey: "areaDesc")
            }
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "entry"){
            self.parsedArray.append(self.tempDict)
            self.entryNumber += 1
            self.entryFound = false
        }
        if (elementName == "cap:event"){
            self.eventFound = false
        }
        if (elementName == "summary"){
            self.summaryFound = false
        }
        if (elementName == "cap:effective"){
            self.effectiveFound = false
        }
        if (elementName == "cap:expires"){
            self.expiresFound = false
        }
        if (elementName == "cap:urgency"){
            self.urgencyFound = false
        }
        if (elementName == "cap:severity"){
            self.severityFound = false
        }
        if (elementName == "cap:certainty"){
            self.certaintyFound = false
        }
        if (elementName == "id"){
            self.linkFound = false
        }
        if (elementName == "cap:polygon"){
            self.polygonFound = false
        }
        if (elementName == "cap:areaDesc"){
            self.areaDescFound = false
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        if (self.parsedArray[0] == self.tempDict){
            self.parsedArray = []
        }
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        print(parseError.localizedDescription)
    }
    
}