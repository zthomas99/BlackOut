import Foundation
@preconcurrency import Firebase
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore

protocol CommentServicing {
	func submitReply(postId: String, comment: String, advice: Advice, completion: @Sendable @escaping (Error?) -> Void)
	func submitReplyToReply(postId: String, comment: String, advice: Advice, reply: Reply, completion: @Sendable @escaping (Error?) -> Void)
	func submitAdvice(postId: String, comment: String, completion: @Sendable @escaping (Error?) -> Void)
	func incrementAdviceCommentCount(postId: String, adviceId: String, completion: @Sendable @escaping () -> Void)
	func incrementReplyCount(postId: String)
	func setVoters(postId: String, adviceId: String, upVoters: [String], downVoters: [String], completion: @Sendable @escaping (Error?) -> Void)
}

final class CommentService: CommentServicing, @unchecked Sendable {
	static let shared = CommentService()
	private let db = Firestore.firestore()
	private let incidentReference: DatabaseReference
	let commentReference: CollectionReference

	private init() {
		incidentReference = Database.database().reference().child("incidents")
		commentReference = db.collection("comments")
	}

	func submitReply(postId: String, comment: String, advice: Advice, completion: @Sendable @escaping (Error?) -> Void) {
		guard let user = Auth.auth().currentUser?.displayName else { return }
		let date = String(describing: Date())
		commentReference.document(postId).collection("Advices").document(advice.id).collection("Replies").addDocument(data: [
			"username": user,
			"date": date,
			"comment": comment,
			"isExpanded": false,
			"quoteUser": "",
			"quoteId": "",
			"hasReply": false
		]) { err in
			if let err = err {
				completion(err)
			} else {
				let adviceRef = self.commentReference.document(postId).collection("Advices").document(advice.id)
				adviceRef.updateData(["hasReply": true]) { err in
					if let err = err {
						completion(err)
					} else {
						self.incrementReplyCount(postId: postId)
						self.incrementAdviceCommentCount(postId: postId, adviceId: advice.id, completion: {
							completion(nil)
						})
					}
				}
			}
		}
	}

	func submitReplyToReply(postId: String, comment: String, advice: Advice, reply: Reply, completion: @Sendable @escaping (Error?) -> Void) {
		guard let user = Auth.auth().currentUser?.displayName else { return }
		let date = String(describing: Date())
		commentReference.document(postId).collection("Advices").document(advice.id).collection("Replies").addDocument(data: [
			"username": user,
			"date": date,
			"comment": comment,
			"quoteUser": reply.user,
			"quoteId": reply.id,
			"hasReply": true
		]) { err in
			if let err = err {
				completion(err)
			} else {
				self.incrementReplyCount(postId: postId)
				self.incrementAdviceCommentCount(postId: postId, adviceId: advice.id, completion: {
					completion(nil)
				})
			}
		}
	}

	func submitAdvice(postId: String, comment: String, completion: @Sendable @escaping (Error?) -> Void) {
		let upVoters = [String]()
		let downVoters = [String]()
		guard let user = Auth.auth().currentUser?.displayName else { return }
		let date = String(describing: Date())
		commentReference.document(postId).collection("Advices").addDocument(data: [
			"username": user,
			"date": date,
			"hasReply": false,
			"comment": comment,
			"commentCount": 0,
			"upVoters": upVoters,
			"downVoters": downVoters
		]) { err in
			if let err = err {
				completion(err)
			} else {
				self.incrementReplyCount(postId: postId)
				completion(nil)
			}
		}
	}

	func incrementAdviceCommentCount(postId: String, adviceId: String, completion: @Sendable @escaping () -> Void) {
		let adviceRef = commentReference.document(postId).collection("Advices").document(adviceId)
		db.runTransaction({ (transaction, errorPointer) -> Any? in
			let adviceDoc: DocumentSnapshot
			do {
				try adviceDoc = transaction.getDocument(adviceRef)
			} catch let fetchError as NSError {
				errorPointer?.pointee = fetchError
				return nil
			}
			guard let oldCount = adviceDoc.data()?["commentCount"] as? Int else {
				let error = NSError(
					domain: "AppErrorDomain",
					code: -1,
					userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve comment count from snapshot \(adviceDoc)"])
				errorPointer?.pointee = error
				return nil
			}
			transaction.updateData(["commentCount": oldCount + 1], forDocument: adviceRef)
			return nil
		}) { object, error in
			completion()
		}
	}

	func incrementReplyCount(postId: String) {
		let postRef = incidentReference.child(postId)
		postRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
			if var post = currentData.value as? [String: AnyObject] {
				var replyCount = post["replyCount"] as? Int ?? 0
				replyCount += 1
				post["replyCount"] = replyCount as AnyObject?
				currentData.value = post
				return TransactionResult.success(withValue: currentData)
			}
			return TransactionResult.success(withValue: currentData)
		}) { error, committed, snapshot in
		}
	}

	func setVoters(postId: String, adviceId: String, upVoters: [String], downVoters: [String], completion: @Sendable @escaping (Error?) -> Void) {
		let adviceRef = commentReference.document(postId).collection("Advices").document(adviceId)
		db.runTransaction({ (transaction, errorPointer) -> Any? in
			transaction.updateData(["upVoters": upVoters, "downVoters": downVoters], forDocument: adviceRef)
			return nil
		}) { object, error in
			completion(error)
		}
	}
}
