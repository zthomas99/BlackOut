import Foundation
@preconcurrency import Firebase
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore

protocol UserServicing {
	func addUserAccount(user: User)
	func updateTokens(userId: String, data: String, completion: @Sendable @escaping (_ error: Error?) -> ())
	func removeToken(userId: String, data: String, completion: @Sendable @escaping (_ error: Error?) -> ())
	func retrieveCurrentUser(completion: @Sendable @escaping (_ error: Error?) -> ())
	func retrieveBlockedUsers(completion: @Sendable @escaping ([String]) -> ())
	func addBlockedUser(username: String, completion: @Sendable @escaping (Error?) -> Void)
	func unblockUsers(username: String, completion: @Sendable @escaping (Error?) -> Void)
}

final class UserService: UserServicing, @unchecked Sendable {
	static let shared = UserService()
	private let db = Firestore.firestore()
	private let userReference: CollectionReference

	private init() {
		userReference = db.collection("users")
	}

	private func parseUsername(from email: String?) -> String? {
		guard let email = email, let atRange = email.range(of: "@") else { return nil }
		return String(email[email.startIndex..<atRange.lowerBound])
	}

	func addUserAccount(user: User) {
		guard let username = parseUsername(from: user.email) else { return }
		let blockedUsers = [String]()
		userReference.document(user.uid).setData([
			"userId": user.uid,
			"username": username,
			"blockedUsers": blockedUsers
		])
	}

	func updateTokens(userId: String, data: String, completion: @Sendable @escaping (_ error: Error?) -> ()) {
		userReference.document(userId).setData(["fcmTokens": FieldValue.arrayUnion([data])], merge: true) { error in
			completion(error)
		}
	}

	func removeToken(userId: String, data: String, completion: @Sendable @escaping (_ error: Error?) -> ()) {
		userReference.document(userId).setData(["fcmTokens": FieldValue.arrayRemove([data])], merge: true) { error in
			completion(error)
		}
	}

	func retrieveCurrentUser(completion: @Sendable @escaping (_ error: Error?) -> ()) {
		guard let userID = CurrentUserStatus.shared.userId else {
			completion(nil)
			return
		}
		let user = CurrentUserStatus.shared.user
		userReference.document(userID).getDocument { [weak self] snapshot, error in
			if let error = error {
				completion(error)
				return
			}
			guard let snapshot = snapshot else {
				completion(nil)
				return
			}
			if snapshot.exists {
				let userSnap = SnapToUserAccount(with: snapshot)
				if userSnap?.currentUser != nil {
					UserAccount.shared = userSnap?.currentUser
					completion(nil)
				} else {
					let username = self?.parseUsername(from: user?.email)
					UserAccount.shared?.id = user?.uid
					UserAccount.shared?.username = username
					completion(nil)
				}
			} else {
				let username = self?.parseUsername(from: user?.email)
				UserAccount.shared?.id = user?.uid
				UserAccount.shared?.username = username
				if let user = user {
					self?.addUserAccount(user: user)
				}
				completion(nil)
			}
		}
	}

	func retrieveBlockedUsers(completion: @Sendable @escaping ([String]) -> ()) {
		guard let userId = Auth.auth().currentUser?.uid else {
			completion([])
			return
		}
		userReference.document(userId).getDocument { snapshot, err in
			if err != nil {
				completion([])
				return
			}
			guard let snapshot = snapshot, snapshot.exists else {
				completion([])
				return
			}
			let blockedUsers = snapshot.data()?["blockedUsers"] as? [String] ?? []
			completion(blockedUsers)
		}
	}

	func addBlockedUser(username: String, completion: @Sendable @escaping (Error?) -> Void) {
		let currentUserId = String(describing: Auth.auth().currentUser?.uid ?? "")
		let blockedRef = userReference.document(currentUserId)
		db.runTransaction({ (transaction, errorPointer) -> Any? in
			let userDoc: DocumentSnapshot
			do {
				try userDoc = transaction.getDocument(blockedRef)
			} catch let fetchError as NSError {
				errorPointer?.pointee = fetchError
				return nil
			}
			let blockedUsers = userDoc.data()?["blockedUsers"] as? [String]
			if blockedUsers == nil {
				let createdBlockedUsers: [String] = [username]
				blockedRef.setData(["blockedUsers": createdBlockedUsers])
				return nil
			} else {
				var newBlockedUsers = blockedUsers ?? []
				newBlockedUsers.append(username)
				transaction.setData(["blockedUsers": newBlockedUsers], forDocument: blockedRef, merge: true)
				return nil
			}
		}) { object, error in
			completion(error)
		}
	}

	func unblockUsers(username: String, completion: @Sendable @escaping (Error?) -> Void) {
		let currentUserID = String(describing: Auth.auth().currentUser?.uid ?? "")
		let blockedRef = userReference.document(currentUserID)
		db.runTransaction({ (transaction, errorPointer) -> Any? in
			let userDoc: DocumentSnapshot
			do {
				try userDoc = transaction.getDocument(blockedRef)
			} catch let fetchError as NSError {
				errorPointer?.pointee = fetchError
				return nil
			}
			var blockedUsers = userDoc.data()?["blockedUsers"] as? [String]
			guard let index = blockedUsers?.firstIndex(of: username) else {
				return nil
			}
			blockedUsers?.remove(at: index)
			if let blockedUsers = blockedUsers {
				transaction.setData(["blockedUsers": blockedUsers], forDocument: blockedRef)
			}
			return nil
		}) { object, error in
			completion(error)
		}
	}
}
