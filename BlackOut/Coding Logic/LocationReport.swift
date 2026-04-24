//
//  LocationReport.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/30/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import Foundation
import FirebaseStorage

struct LocationReport : Hashable
{
	let postId: String
	let businessName: String
	let businessLocation: String
	let businessCity : String
	let state : String
	let zipCode : String
	let incidentReports: [String]
	let hasMediaFiles : Bool
	var profilePhotos : [String]?
	var mediaList = [String]()
	
	init?(postId: String, dict: [String: Any])
	{
		self.postId = postId
		guard let businessLocation = dict["businessLocation"] as? String,
			let businessName = dict["businessName"] as? String,
			let businessCity = dict["businessCity"] as? String,
			let state = dict["state"] as? String,
			let zipCode = dict["zipCode"] as? String,
			let incidentReports = dict["incidentReports"] as? [String],
			let hasMediaFiles = dict["hasMediaFiles"] as? Bool
			else {return nil}
		
		let profilePhotos = dict["profiles"] as? [String]
		
		self.businessName = businessName
		self.businessLocation = businessLocation
		self.businessCity = businessCity
		self.state = state
		self.incidentReports = incidentReports
		self.hasMediaFiles = hasMediaFiles
		self.zipCode = zipCode
		self.profilePhotos = profilePhotos
	}
	
	init(postId: String, businessLocation : String, businessName: String,
		 businessCity : String, state:String, zipCode: String, incidentReports: [String], hasMediaFiles: Bool, profilePhotos: [String]?)
	{
		self.postId = postId
		self.businessName = businessName
		self.businessLocation = businessLocation
		self.businessCity = businessCity
		self.state = state
		self.incidentReports = incidentReports
		self.hasMediaFiles = hasMediaFiles
		self.zipCode = zipCode
		self.profilePhotos = profilePhotos
	}
	
	mutating func setMediaList(list: [String])
	{
		self.mediaList = list
	}
	
	func hash(into hasher: inout Hasher)
	{
		hasher.combine(postId)
	}
}
