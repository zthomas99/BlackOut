//
//  FireDatabaseService.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 10/18/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import Foundation
import Firebase
import FirebaseCore
import FirebaseFirestore

class FireDatabaseService{
	static let shared = FireDatabaseService()
	static let db = Firestore.firestore()
	init(){}
	
	let incidentReference = Database.database().reference().child("incidents")
	let locationReference = db.collection("locations")
	let commentReference = db.collection("comments")
	let userReference = db.collection("users")
	let flagReference = Database.database().reference().child("flags")
	
	//MARK: - Location Search Functions
	
	func RetireveLocations(search : String, searchType: String, completion: @escaping ([LocationReport]) -> ())
	{
		var locations = [LocationReport]()
		switch(searchType)
        {
        case "city" :
        FireDatabaseService.shared.locationReference.whereField("businessCity", isEqualTo: search)
            .getDocuments()
            {(locationSnapshot, err) in
                if let err = err{print("Error getting documents for city search: \(err)")}
                else
                {
                    DispatchQueue.main.async {
                        guard let locationReportSnap = LocationSnapHelper(with: locationSnapshot!) else
                        {
                        completion(locations)
                        return
                        }
						locations = locationReportSnap.reportLocations
						completion(locations)
                    }
                }

            }
        case "state" :
            FireDatabaseService.shared.locationReference.whereField("state", isEqualTo: search)
            .getDocuments()
            {(locationSnapshot, err) in
                if let err = err{print("Error getting documents for city search: \(err)")}
                else
                {
                    DispatchQueue.main.async {
                        guard let locationReportSnap = LocationSnapHelper(with: locationSnapshot!) else
                        {
                        completion(locations)
                        return
                        }
						locations = locationReportSnap.reportLocations
                        completion(locations)
                    }
                }

            }
         case "zipCode" :
            FireDatabaseService.shared.locationReference.whereField("zipCode", isEqualTo: search)
            .getDocuments()
            {(locationSnapshot, err) in
                if let err = err{print("Error getting documents for city search: \(err)")}
                else
                {
                    DispatchQueue.main.async {
                        guard let locationReportSnap = LocationSnapHelper(with: locationSnapshot!) else
                        {
						completion(locations)
                        return
                        }
						locations = locationReportSnap.reportLocations
                        completion(locations)
                    }
                }

            }
        case "invalid" :
           completion(locations)
		default:
			completion(locations)
		}
	}
	
	//MARK: - Edit Report Functions
	
	func SetReportDescription(reportID: String, description:String)
	{
		incidentReference.child(reportID).updateChildValues(["descriptionMessage" : description])
	}
	//MARK: - Profile Report Functions
	
	func RetrieveReports(withUser user:String, completion: @escaping ([IncidentReport]) ->())
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
	
	func RetrieveCommentMetadata(withReports reports:[IncidentReport], completion: @escaping ([String : CommentMetadata]) ->())
	{
		var commentMap = [String : CommentMetadata]()
		var docCommentCount = 0
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
					var adviceCount = snapshot?.data()?["adviceCount"] as? Int
					var commentCount = snapshot?.data()?["commentCount"] as? Int
					
					if adviceCount == nil
					{
						adviceCount = 0
					}
					
					if commentCount == nil
					{
						commentCount = 0
					}
					docCommentCount += 1
					commentMap[report.postId] = CommentMetadata(adviceCount: adviceCount, commentCount: commentCount)
					
					if docCommentCount == reports.count
					{
						completion(commentMap)
					}
				}
			})
			
		}
	}
	
	//MARK: - User Functions
	func AddUserAccount(user: User)
	{
		let range = user.email!.range(of: "@")
		let username = user.email![(user.email!.startIndex)..<range!.lowerBound]
	
		let blockedUsers = [String]()
		userReference.document(user.uid).setData(["userId" : user.uid,
												  "username" : username,
												  "blockedUsers" : blockedUsers])
	}
	
	func UpdateTokens(userId: String, data: String, completion: @escaping (_ error:Error?) -> ())
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
	
	func RemoveToken(userId: String, data: String, completion: @escaping (_ error:Error?) -> ())
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
	
	func RetrieveCurrentUser(completion: @escaping (_ error:Error?) ->())
	{
		let userID = CurrentUserStatus.shared.userId
		let user = CurrentUserStatus.shared.user
		self.userReference.document(userID!).getDocument(completion: {
			(snapshot, error)
			in
			if error == nil
			{
				if snapshot!.exists
				{
					let userSnap = SnapToUserAccount.init(with: snapshot!)
					if userSnap?.currentUser != nil
					{
						UserAccount.shared = userSnap?.currentUser
						completion(error)
					}
					else
					{
						let range = user?.email?.range(of: "@")
						let username = user?.email![(user?.email!.startIndex)!..<range!.lowerBound]
						UserAccount.shared?.id = user?.uid
						UserAccount.shared?.username = String(username!)
						completion(error)
					}
				}
				else
				{
					let range = user?.email?.range(of: "@")
					let username = user?.email![(user?.email!.startIndex)!..<range!.lowerBound]
					UserAccount.shared?.id = user?.uid
					UserAccount.shared?.username = String(username!)
					self.AddUserAccount(user: user!)
					completion(error)
				}
			}
			else
			{
				completion(error)
			}
		})
		
	}
	// MARK: - Block User Functions
	func RetrieveBlockedUsers(completion: @escaping ([String]) -> ())
	{
		var blockedUsers = [String]()
		let userId = Auth.auth().currentUser?.uid
		userReference.document(userId!).getDocument(completion: {
			(snapshot, err)
			in
			if err != nil
			{
				print("Failed to retrieve blocked users for user with id : \(String(describing: userId)) error : \(String(describing: err))")
				completion(blockedUsers)
			}
			
			if (snapshot?.exists)!
			{
				if snapshot?.data()?["blockedUsers"] != nil
				{
					
					blockedUsers = snapshot?.data()?["blockedUsers"] as! [String]
				}
				completion(blockedUsers)
			}
		})
	}
	
		func AddBlockedUser(username: String, completion: @escaping (Error?) -> Void)
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
				var newBlockedUsers = blockedUsers
				newBlockedUsers?.append(username)
				transaction.setData(["blockedUsers": newBlockedUsers!], forDocument: blockedRef, merge: true)
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
		
		func UnblockUsers(username: String, completion: @escaping (Error?) -> Void)
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
			let index = blockedUsers?.index(of: username)
			if index! > -1
			{
				blockedUsers?.remove(at: index!)
				transaction.setData(["blockedUsers" : blockedUsers!], forDocument: blockedRef)
				return nil
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
		func SubmitReply(postId: String, comment: String, advice: Advice, completion: @escaping (Error?) -> Void)
		{
			let user : String = (Auth.auth().currentUser?.displayName)!
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
							self.IncrementReplyCount(postId: postId)
							self.IncrementAdviceCommentCount(postId: postId, adviceId: advice.id, completion: {
								completion(nil)
							})
						}
					}
				}
			}
		}
		
		func SubmitReplyToReply(postId: String, comment: String, advice: Advice, reply: Reply, completion: @escaping (Error?) -> Void)
		{
			let user : String = (Auth.auth().currentUser?.displayName)!
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
					self.IncrementReplyCount(postId: postId)
					self.IncrementAdviceCommentCount(postId: postId, adviceId: advice.id, completion: {
						completion(nil)
					})
					
				}
			}
		}
	
	func SubmitAdvice(postId: String, comment : String) -> Any?
	{
		let upVoters = [String]()
		let downVoters = [String]()
		let user = Auth.auth().currentUser?.displayName
		let date = String(describing : Date())
		var error : Any?
		//create data to pass to the FirebaseStore
		commentReference.document(postId).collection("Advices").addDocument(data:
			["username" : user!,
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
				self.IncrementReplyCount(postId: postId)
			}
			
		}
		return error
	}
	
	func IncrementAdviceCommentCount(postId: String, adviceId: String, completion: @escaping () -> Void)
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
	
	func IncrementReplyCount(postId : String)
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
	
		func SetVoters(postId: String, adviceId: String, upVoters: [String], downVoters:[String], completion: @escaping (Error?) -> Void)
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
	func RetrieveMediaList(location: LocationReport, completion: @escaping ([String]) -> ())
	{
		var mediaList = [String]()
		let reportCount = location.incidentReports.count
		var reportCounter = 0
		for report in location.incidentReports
		{
			let reportRef = locationReference.document(location.postId).collection("reports").document(report)
			
			reportRef.getDocument
				{
					(snapshot, err) in
					if let err = err
					{
						reportCounter += 1
						print("There was an error in querying the documents for the following post id  : \(location.postId) error : \(err)")
						if reportCount == reportCounter
						{
							completion(mediaList)
						}
					}
					else
					{
						if snapshot!.exists
						{
							let mediaArry = snapshot!.data()?["media"] as! [String : [String]]
							for media in  mediaArry.values
							{
								mediaList.append(media[0])
							}
							
							reportCounter += 1
							
							if reportCount == reportCounter
							{
								completion(mediaList)
							}
						}
						else
						{
							reportCounter += 1
							if reportCount == reportCounter
							{
								completion(mediaList)
							}
						}
					}
			}
		}
	}

	func RetrieveMediaLists(locations: [LocationReport], completion: @escaping ([String: [String]]) -> ())
	{	let locationCount = locations.count
		var locationCounter = 0
		var mediaList = [String : [String]]()
		for location in locations
		{
			if location.hasMediaFiles
			{
				let reportCount = location.incidentReports.count
				var reportCounter = 0
				for report in location.incidentReports
				{
					let reportRef = locationReference.document(location.postId).collection("reports").document(report)
					
					reportRef.getDocument
						{
							(snapshot, err) in
							if let err = err
							{
								reportCounter += 1
								
								if reportCounter == reportCount
								{
									locationCounter += 1
								}
								print("There was an error in querying the documents for the following post id  : \(location.postId) error : \(err)")
								if locationCounter == locationCount
								{
									completion(mediaList)
								}
							}
							else
							{
								if snapshot!.exists
								{
									let mediaArry = snapshot!.data()?["media"] as! [String : [String]]
									var fileList = [String]()
									for media in  mediaArry.values
									{
										fileList.append(media[0])
									}
									mediaList[location.postId] = fileList
									reportCounter += 1
									
									if reportCount == reportCounter
									{
										locationCounter += 1
									}
									if locationCounter == locationCount
									{
										completion(mediaList)
									}
								}
							}
					}
				}
			}
			else
			{
				locationCounter += 1
				if locationCounter == locationCount
				{
					completion(mediaList)
				}
			}
		}
	}
		func InsertNoMediaChild(reference : DatabaseReference, completion: @escaping () -> ())
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
		
		func AddMediaToReference(reference:DatabaseReference, media: String, completion: @escaping () ->())
		{
			reference.child("incidentMedia").childByAutoId().observeSingleEvent(of: .value, with: {(snapshot) in
				
				if snapshot.exists()
				{
					let mediaArr : [String] = snapshot.value as! [String]
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
