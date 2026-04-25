//
//  User.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/12/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
struct UserAccount {
	var id : String!
	var username: String!
	var blockedUsers = [String]()
	var fcmTokens = [String]()
	
	nonisolated(unsafe) static var shared = UserAccount()
	
	init?(id:String, dict:[String:Any])
	{
		self.id = id
		guard let username = dict["username"] as? String
		else {return nil}
		
		let blockedUsers = dict["blockedUsers"] as? [String]
		if let fcmTokens = dict["fcmTokens"] as? [String]
		{
			self.fcmTokens = fcmTokens
		}
		self.username = username
		self.blockedUsers = blockedUsers!
	}
	
	init?()
	{
		
	}
}

