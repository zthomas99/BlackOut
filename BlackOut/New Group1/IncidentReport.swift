//
//  IncidentReport.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 10/18/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import Foundation
import Photos
import FirebaseFirestore

struct IncidentReport : Hashable
{
    let postId: String
    let businessName: String
    let descriptionMessage: String
	let reportTitle : String
    let businessLocation: String
    let businessPhoto: String
    let username: String
	let replyCount : Int
    let date: Date
    let businessCity : String
    let state : String
    let zipCode : String
    
    var incidentMedia: [String : [String]]?
    //initialize incident report
    
    init?(postId: String, dict: [String: Any])
    {
        self.postId = postId
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        guard let username = dict["username"] as? String,
        let businessName = dict["businessName"] as? String,
        let descriptionMessage = dict["descriptionMessage"] as? String,
		let reportTitle = dict["reportTitle"] as? String,
        let businessLocation = dict["businessLocation"] as? String,
        let businessPhoto = dict["businessPhoto"] as? String,
		let replyCount = dict["replyCount"] as? Int,
        let dateString = dict["date"] as? String,
        let date = dateFormatter.date(from: dateString),
        let businessCity = dict["businessCity"] as? String,
        let state = dict["state"] as? String,
        let zipCode = dict["zipCode"] as? String
        else {return nil}
        
        let incidentMedia = dict["incidentMedia"] as? [String : [String]]
        
		self.reportTitle = reportTitle
        self.descriptionMessage = descriptionMessage
        self.businessName = businessName
        self.username = username
        self.businessPhoto = businessPhoto
		self.replyCount = replyCount
        self.businessLocation = businessLocation
        self.incidentMedia = incidentMedia
        self.businessCity = businessCity
        self.state = state
        self.zipCode = zipCode
        self.date = date
    }
	
	func hash(into hasher: inout Hasher)
	{
		hasher.combine(postId)
	}
}
