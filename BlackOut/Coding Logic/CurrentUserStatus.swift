//
//  CurrentUserStatus.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/26/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import FirebaseAuth
public class CurrentUserStatus
{
	static let  shared = CurrentUserStatus()
	var user : User?
	var userId : String?
	
	init() {
		Auth.auth().addStateDidChangeListener({
			(auth, user)
			in
			
			self.user = auth.currentUser
			self.userId = auth.currentUser?.uid
			
		})
	}

}

