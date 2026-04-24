//
//  AdviceComment.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/7/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import FirebaseStorage

struct Advice {
	var id : String
	var date : Date
	var user : String
	var comment : String
	var commentCount: Int
	var hasReply : Bool
	var upVoters : [String]?
	var downVoters : [String]?
	var isExpanded : Bool
	var replies : [Reply]?
	
	init?(id: String, dict: [String: Any])
	{
		self.id = id
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
		guard let user = dict["username"] as? String,
		let dateString = dict["date"] as? String,
		let date = dateFormatter.date(from: dateString),
		let hasReply = dict["hasReply"] as? Bool,
		let commentCount = dict["commentCount"] as? Int,
		let comment = dict["comment"] as? String
		else {return nil}
		
		let upVoters = dict["upVoters"] as? [String]
		let downVoters = dict["downVoters"] as? [String]
		let isExpanded = false
		
		self.date = date
		self.user = user
		self.upVoters = upVoters
		self.downVoters = downVoters
		self.hasReply = hasReply
		self.commentCount = commentCount
		self.comment = comment
		self.isExpanded = isExpanded
	}
}
