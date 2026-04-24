//
//  ReplyComment.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/7/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Reply: Hashable {
	let id : String
	let ref : DocumentReference
	let date : Date
	let user : String
	let quoteUser: String
	let quoteId: String
	let comment : String
	let hasReply : Bool

	
	
	init?(id: String, reference: DocumentReference, dict: [String: Any])
	{
		self.id = id
		self.ref = reference
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
		guard let username = dict["username"] as? String,
		let dateString = dict["date"] as? String,
		let date = dateFormatter.date(from: dateString),
		let quoteUser = dict["quoteUser"] as? String,
		let quoteId = dict["quoteId"] as? String,
		let hasReply = dict["hasReply"] as? Bool,
		let comment = dict["comment"] as? String
		else {return nil}
		
		self.date = date
		self.user = username
		self.quoteUser = quoteUser
		self.quoteId = quoteId
		self.hasReply = hasReply
		self.comment = comment
	}
	func hash(into hasher: inout Hasher)
	{
		hasher.combine(id)
	}
}
