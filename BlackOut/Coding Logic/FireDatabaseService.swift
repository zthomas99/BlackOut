//
//  FireDatabaseService.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 10/18/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import Foundation
@preconcurrency import Firebase
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore

class FireDatabaseService: @unchecked Sendable {
	static let shared = FireDatabaseService()
	nonisolated(unsafe) static let db = Firestore.firestore()
	init(){}

	private final class Box<T>: @unchecked Sendable {
		var value: T
		init(_ value: T) { self.value = value }
	}
	
	private func parseUsername(from email: String?) -> String? {
		guard let email = email, let atRange = email.range(of: "@") else { return nil }
		return String(email[email.startIndex..<atRange.lowerBound])
	}
	
	let incidentReference = Database.database().reference().child("incidents")
	let locationReference = db.collection("locations")
	let commentReference = db.collection("comments")
	let userReference = db.collection("users")
	let flagReference = Database.database().reference().child("flags")
	
	//MARK: - Location Search Functions
	
	func retrieveLocations(search: String, searchType: String, completion: @Sendable @escaping ([LocationReport]) -> ()) {
		let field: String
		switch searchType {
		case "city": field = "businessCity"
		case "state": field = "state"
		case "zipCode": field = "zipCode"
		default:
			completion([])
			return
		}

		FireDatabaseService.shared.locationReference.whereField(field, isEqualTo: search)
			.getDocuments { locationSnapshot, err in
				if let err = err {
					print("Error getting documents for \(searchType) search: \(err)")
					completion([])
					return
				}
				DispatchQueue.main.async {
					guard let locationSnapshot = locationSnapshot,
						  let locationReportSnap = LocationSnapHelper(with: locationSnapshot) else {
						completion([])
						return
					}
					completion(locationReportSnap.reportLocations)
				}
			}
	}
	
	//MARK: - Edit Report Functions
	
	func setReportDescription(reportID: String, description:String)
	{
		incidentReference.child(reportID).updateChildValues(["descriptionMessage" : description])
	}
	//MARK: - Profile Report Functions
	
	func retrieveReports(withUser user:String, completion: @Sendable @escaping ([IncidentReport]) ->())
	{
		var reports = [IncidentReport]()
		incidentReference.queryOrdered(byChild: "username").queryEqual(toValue: user).observeSingleEvent(of: .value, with:
			{
				(snapshot)
				in
				if snapshot.exists()
				{
					guard let snapConverter = SnapToReports.init(with: snapshot)
						else
					{
						print("Failed to convert snapshot to incident reports for user : \(user)")
						completion(reports)
						return
					}
					reports = snapConverter.reports
					completion(reports)
				}
		})
	}
	
	func retrieveCommentMetadata(withReports reports:[IncidentReport], completion: @Sendable @escaping ([String : CommentMetadata]) ->())
	{
		let state = Box((count: 0, map: [String: CommentMetadata]()))
		for report in reports
		{
			commentReference.document(report.postId).getDocument(completion: {
				(snapshot, error)
				in
				if error != nil
				{
					print("Failed to retrive document for report with id \(report.postId)")
				}
				else
				{
					let adviceCount = snapshot?.data()?["adviceCount"] as? Int ?? 0
					let commentCount = snapshot?.data()?["commentCount"] as? Int ?? 0

					state.value.count += 1
					state.value.map[report.postId] = CommentMetadata(adviceCount: adviceCount, commentCount: commentCount)

					if state.value.count == reports.count
					{
						completion(state.value.map)
					}
				}
			})
		}
	}
	
	//MARK: - User Functions
	func addUserAccount(user: User)
	{
		guard let username = parseUsername(from: user.email) else { return }
	
		let blockedUsers = [String]()
		userReference.document(user.uid).setData(["userId" : user.uid,
												  "username" : username,
												  "blockedUsers" : blockedUsers])
	}
	
	func updateTokens(userId: String, data: String, completion: @Sendable @escaping (_ error:Error?) -> ())
	{
		userReference.document(userId).setData(["fcmTokens": FieldValue.arrayUnion([data])], merge: true){
			(error)
			in
			
			if let error = error
			{
				print("failed to update user fcm tokens due to the following error: \(error)")
				completion(error)
			}
			else
			{
				completion(error)
			}
		}
	}
	
	func removeToken(userId: String, data: String, completion: @Sendable @escaping (_ error:Error?) -> ())
	{
		userReference.document(userId).setData(["fcmTokens": FieldValue.arrayRemove([data])], merge: true){
			(error)
			in
			
			if let error = error
			{
				print("failed to update user fcm tokens due to the following error: \(error)")
				completion(error)
			}
			else
			{
				completion(error)
			}
		}
	}
	
	func retrieveCurrentUser(completion: @Sendable @escaping (_ error:Error?) ->())
	{
		guard let userID = CurrentUserStatus.shared.userId else {
			completion(nil)
			return
		}
		let user = CurrentUserStatus.shared.user
		self.userReference.document(userID).getDocument(completion: { [weak self]
			(snapshot, error)
			in
			if let error = error {
				completion(error)
				return
			}
			guard let snapshot = snapshot else {
				completion(nil)
				return
			}
			if snapshot.exists
			{
				let userSnap = SnapToUserAccount.init(with: snapshot)
				if userSnap?.currentUser != nil
				{
					UserAccount.shared = userSnap?.currentUser
					completion(nil)
				}
				else
				{
					let username = self?.parseUsername(from: user?.email)
					UserAccount.shared?.id = user?.uid
					UserAccount.shared?.username = username
					completion(nil)
				}
			}
			else
			{
				let username = self?.parseUsername(from: user?.email)
				UserAccount.shared?.id = user?.uid
				UserAccount.shared?.username = username
				if let user = user {
					self?.addUserAccount(user: user)
				}
				completion(nil)
			}
		})
		
	}
	// MARK: - Block User Functions
	func retrieveBlockedUsers(completion: @Sendable @escaping ([String]) -> ())
	{
		guard let userId = Auth.auth().currentUser?.uid else {
			completion([])
			return
		}
		userReference.document(userId).getDocument(completion: {
			(snapshot, err)
			in
			if let err = err
			{
				print("Failed to retrieve blocked users for user with id : \(userId) error : \(err)")
				completion([])
				return
			}

			guard let snapshot = snapshot, snapshot.exists else {
				completion([])
				return
			}
			let blockedUsers = snapshot.data()?["blockedUsers"] as? [String] ?? []
			completion(blockedUsers)
		})
	}
	
		func addBlockedUser(username: String, completion: @Sendable @escaping (Error?) -> Void)
		{
			let currentUserId = String(describing: Auth.auth().currentUser?.uid ?? "")
			let blockedRef = userReference.document(currentUserId)
		FireDatabaseService.db.runTransaction({(transaction, errorPointer) -> Any? in
			
			let userDoc : DocumentSnapshot
			do{
				try userDoc = transaction.getDocument(blockedRef)
			} catch let fetchError  as NSError{
				errorPointer?.pointee = fetchError
				return nil
			}
			
			let blockedUsers = userDoc.data()?["blockedUsers"] as? [String]
			if blockedUsers == nil
			{
				let createdBlockedUsers : [String]  = [username]
				blockedRef.setData(["blockedUsers": createdBlockedUsers])
				return nil
			}
			else
			{
				var newBlockedUsers = blockedUsers ?? []
				newBlockedUsers.append(username)
				transaction.setData(["blockedUsers": newBlockedUsers], forDocument: blockedRef, merge: true)
				return nil
			}
		})
			{
				(object, error) in
				if let error = error
				{
					print("Update Voters Transaction Failed: \(error)")
					completion(error)
				}
				else
				{
					print("Update Voters Transaction successfully committed!")
					completion(nil)
				}
			}
		}
		
		func unblockUsers(username: String, completion: @Sendable @escaping (Error?) -> Void)
		{
			let currentUserID = String(describing: Auth.auth().currentUser?.uid ?? "")
			let blockedRef = userReference.document(currentUserID)
		FireDatabaseService.db.runTransaction({(transaction, errorPointer) -> Any? in
			
			let userDoc : DocumentSnapshot
			
			do{
				try userDoc = transaction.getDocument(blockedRef)
			}catch let fetchError as NSError{
				errorPointer?.pointee = fetchError
				return nil
			}
			
			var blockedUsers = userDoc.data()?["blockedUsers"] as? [String]
			guard let index = blockedUsers?.firstIndex(of: username) else {
				return nil
			}
			blockedUsers?.remove(at: index)
			if let blockedUsers = blockedUsers {
				transaction.setData(["blockedUsers" : blockedUsers], forDocument: blockedRef)
			}
			return nil
		})
			{
				(object, error) in
				if let error = error
				{
					print("Update Voters Transaction Failed: \(error)")
					completion(error)
				}
				else
				{
					print("Update Voters Transaction successfully committed!")
					completion(nil)
				}
			}
		}
		//MARK: - Comment Functions
		func submitReply(postId: String, comment: String, advice: Advice, completion: @Sendable @escaping (Error?) -> Void)
		{
			guard let user = Auth.auth().currentUser?.displayName else { return }
			let date  = String(describing: Date())
			commentReference.document(postId).collection("Advices").document(advice.id).collection("Replies").addDocument(data:
				
			["username" : user,
			 "date"     : date,
			 "comment"  : comment,
			 "isExpanded" : false,
			 "quoteUser" : "",
			 "quoteId" : "",
			 "hasReply" : false
			])
		{
			err
			in
				if let err = err
				{
					print("Failed to add reply due to the following error \(err)")
					completion(err)
				}
				else
				{
				let adviceRef = self.commentReference.document(postId).collection("Advices").document(advice.id)
				adviceRef.updateData(["hasReply" : true])
				{
					err in
					if let err = err
					{
						print("Failed to update has reply for the following advice \(advice.id)  due to the following error \(err)")
					}
						else
						{
							self.incrementReplyCount(postId: postId)
							self.incrementAdviceCommentCount(postId: postId, adviceId: advice.id, completion: {
								completion(nil)
							})
						}
					}
				}
			}
		}
		
		func submitReplyToReply(postId: String, comment: String, advice: Advice, reply: Reply, completion: @Sendable @escaping (Error?) -> Void)
		{
			guard let user = Auth.auth().currentUser?.displayName else { return }
			let date  = String(describing: Date())
			commentReference.document(postId).collection("Advices").document(advice.id).collection("Replies").addDocument(data:
				
			["username" : user,
			 "date"     : date,
			 "comment"  : comment,
			 "quoteUser": reply.user,
			 "quoteId" : reply.id,
			 "hasReply" : true
			])
		{
			err
			in
				if let err = err
				{
					print("Failed to add reply due to the following error \(err)")
					completion(err)
				}
				else
				{
					self.incrementReplyCount(postId: postId)
					self.incrementAdviceCommentCount(postId: postId, adviceId: advice.id, completion: {
						completion(nil)
					})
					
				}
			}
		}
	
	func submitAdvice(postId: String, comment : String) -> Any?
	{
		let upVoters = [String]()
		let downVoters = [String]()
		guard let user = Auth.auth().currentUser?.displayName else { return nil }
		let date = String(describing : Date())
		var error : Any?
		//create data to pass to the FirebaseStore
		commentReference.document(postId).collection("Advices").addDocument(data:
			["username" : user,
			 "date"     : date,
			 "hasReply" : false,
			 "comment"  : comment,
			 "commentCount" : 0,
			 "upVoters" : upVoters,
			 "downVoters" : downVoters
			])
		{
			err in
			if let err = err
			{
				error = err
				print("Failed to add advice due to the following error : \(err)")
			}
			else
			{
				self.incrementReplyCount(postId: postId)
			}
			
		}
		return error
	}
	
	func incrementAdviceCommentCount(postId: String, adviceId: String, completion: @Sendable @escaping () -> Void)
	{
		let adviceRef = commentReference.document(postId).collection("Advices").document(adviceId)
		
		FireDatabaseService.db.runTransaction({
			(transaction, errorPointer) -> Any?
			in
			let adviceDoc : DocumentSnapshot
			do
			{
				try adviceDoc = transaction.getDocument(adviceRef)
			}
			catch let fetchError as NSError{
				errorPointer?.pointee = fetchError
				return nil
			}
			
			guard let oldCount = adviceDoc.data()?["commentCount"] as? Int else
			{
				let error = NSError(
					domain : "AppErrorDomain",
					code   : -1,
					userInfo : [NSLocalizedDescriptionKey : "Unable to retrieve comment count from snapshot \(adviceDoc)"])
				errorPointer?.pointee = error
				return nil
			}
			
			transaction.updateData(["commentCount" : oldCount + 1], forDocument: adviceRef)
			return nil
		}){
			(object, error) in
			if let error = error{
				print("Transaction increment advice comment count failed : \(error)")
			}
			else
			{
				print("Transacation increment advice comment succeeded!")
				completion()
			}
		}
	}
	
	func incrementReplyCount(postId : String)
	{
		let postRef = incidentReference.child(postId)
		postRef.runTransactionBlock({(currentData : MutableData) -> TransactionResult in
			
			if var post = currentData.value as? [String : AnyObject]
			{
				var replyCount = post["replyCount"] as? Int ?? 0
				replyCount += 1
				post["replyCount"] = replyCount as AnyObject?
				
				
				currentData.value = post
				return TransactionResult.success(withValue: currentData)
			}
			return TransactionResult.success(withValue: currentData)
		})
		{(error, committed, snapshot)
			in
			if let error = error{
				print(error.localizedDescription)
			}
		}
	}
	
		func setVoters(postId: String, adviceId: String, upVoters: [String], downVoters:[String], completion: @Sendable @escaping (Error?) -> Void)
		{
			
			let adviceRef = commentReference.document(postId).collection("Advices").document(adviceId)
		FireDatabaseService.db.runTransaction({(transaction, errorPointer) -> Any? in
			
			transaction.updateData(["upVoters" : upVoters, "downVoters" : downVoters], forDocument : adviceRef)
			return nil
		})
			{
				(object, error) in
				if let error = error
				{
					print("Update Voters Transaction Failed: \(error)")
					completion(error)
				}
				else
				{
					print("Update Voters Transaction successfully committed!")
					completion(nil)
				}
			}
		}
	
	//MARK: - Media Functions
	func retrieveMediaList(location: LocationReport, completion: @Sendable @escaping ([String]) -> ())
	{
		let state = Box((counter: 0, list: [String]()))
		let reportCount = location.incidentReports.count
		for report in location.incidentReports
		{
			let reportRef = locationReference.document(location.postId).collection("reports").document(report)

			reportRef.getDocument
				{
					(snapshot, err) in
					if let err = err
					{
						state.value.counter += 1
						print("There was an error in querying the documents for the following post id  : \(location.postId) error : \(err)")
						if reportCount == state.value.counter
						{
							completion(state.value.list)
						}
					}
					else
					{
						if let snapshot = snapshot, snapshot.exists,
						   let mediaArry = snapshot.data()?["media"] as? [String : [String]]
						{
							for media in mediaArry.values
							{
								if let first = media.first {
									state.value.list.append(first)
								}
							}

							state.value.counter += 1

							if reportCount == state.value.counter
							{
								completion(state.value.list)
							}
						}
						else
						{
							state.value.counter += 1
							if reportCount == state.value.counter
							{
								completion(state.value.list)
							}
						}
					}
			}
		}
	}

	func retrieveMediaLists(locations: [LocationReport], completion: @Sendable @escaping ([String: [String]]) -> ())
	{
		let locationCount = locations.count
		let outerState = Box((locationCounter: 0, mediaList: [String: [String]]()))
		for location in locations
		{
			if location.hasMediaFiles
			{
				let reportCount = location.incidentReports.count
				let reportState = Box(0)
				for report in location.incidentReports
				{
					let reportRef = locationReference.document(location.postId).collection("reports").document(report)

					reportRef.getDocument
						{
							(snapshot, err) in
							if let err = err
							{
								reportState.value += 1

								if reportState.value == reportCount
								{
									outerState.value.locationCounter += 1
								}
								print("There was an error in querying the documents for the following post id  : \(location.postId) error : \(err)")
								if outerState.value.locationCounter == locationCount
								{
									completion(outerState.value.mediaList)
								}
							}
							else
							{
								if let snapshot = snapshot, snapshot.exists,
								   let mediaArry = snapshot.data()?["media"] as? [String : [String]]
								{
									var fileList = [String]()
									for media in mediaArry.values
									{
										if let first = media.first {
											fileList.append(first)
										}
									}
									outerState.value.mediaList[location.postId] = fileList
									reportState.value += 1

									if reportCount == reportState.value
									{
										outerState.value.locationCounter += 1
									}
									if outerState.value.locationCounter == locationCount
									{
										completion(outerState.value.mediaList)
									}
								}
							}
					}
				}
			}
			else
			{
				outerState.value.locationCounter += 1
				if outerState.value.locationCounter == locationCount
				{
					completion(outerState.value.mediaList)
				}
			}
		}
	}
		func insertNoMediaChild(reference : DatabaseReference, completion: @Sendable @escaping () -> ())
		{
			let noMediaParam = ["NoMedia" : true]
			reference.setValue(noMediaParam)
			{
				(error, ref)
				in
				if error != nil
				{
					print("Failed to set no media reference for the following reasons: \(String(describing: error))")
				}
				else
				{
					completion()
				}
			}
		}
		
		func addMediaToReference(reference:DatabaseReference, media: String, completion: @Sendable @escaping () ->())
		{
			reference.child("incidentMedia").childByAutoId().observeSingleEvent(of: .value, with: {(snapshot) in
				
				if snapshot.exists(), let mediaArr = snapshot.value as? [String]
				{
					var newMediaArr : [String] = []
					newMediaArr.append(contentsOf: mediaArr)
					newMediaArr.append(media)
					
					if(newMediaArr[0] == " ")
					{
						newMediaArr.remove(at: 0)
					}
					reference.child("incidentMedia").childByAutoId().setValue(newMediaArr){
						(error,ref)
						in
						if error != nil
						{
							print("Failed to set media reference for the following media item \(media)")
						}
						else
						{
							completion()
						}
					}
				}
				else
				{
					var newMediaArr: [String] = []
					newMediaArr.append(media)
					reference.child("incidentMedia").childByAutoId().setValue(newMediaArr)
					{
						(error,ref)
						in
						if error != nil
						{
							print("Failed to set media reference for the following media item \(media) : error - \(String(describing: error))")
						}
						else
						{
							completion()
						}
					}
					
				}
			})
		}
}
