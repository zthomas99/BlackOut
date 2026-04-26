import Foundation
@preconcurrency import Firebase
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore

class FireDatabaseService: @unchecked Sendable {
	static let shared = FireDatabaseService()
	nonisolated(unsafe) static let db = Firestore.firestore()
	init(){}

	let incidentReference = Database.database().reference().child("incidents")
	let locationReference = db.collection("locations")
	let commentReference = db.collection("comments")
	let userReference = db.collection("users")
	let flagReference = Database.database().reference().child("flags")

	// MARK: - Location Search Functions

	func retrieveLocations(search: String, searchType: String, completion: @Sendable @escaping ([LocationReport]) -> ()) {
		LocationService.shared.retrieveLocations(search: search, searchType: searchType, completion: completion)
	}

	// MARK: - Edit Report Functions

	func setReportDescription(reportID: String, description: String) {
		ReportService.shared.setReportDescription(reportID: reportID, description: description)
	}

	// MARK: - Profile Report Functions

	func retrieveReports(withUser user: String, completion: @Sendable @escaping ([IncidentReport]) -> ()) {
		ReportService.shared.retrieveReports(withUser: user, completion: completion)
	}

	func retrieveCommentMetadata(withReports reports: [IncidentReport], completion: @Sendable @escaping ([String: CommentMetadata]) -> ()) {
		ReportService.shared.retrieveCommentMetadata(withReports: reports, completion: completion)
	}

	// MARK: - User Functions

	func addUserAccount(user: User) {
		UserService.shared.addUserAccount(user: user)
	}

	func updateTokens(userId: String, data: String, completion: @Sendable @escaping (_ error: Error?) -> ()) {
		UserService.shared.updateTokens(userId: userId, data: data, completion: completion)
	}

	func removeToken(userId: String, data: String, completion: @Sendable @escaping (_ error: Error?) -> ()) {
		UserService.shared.removeToken(userId: userId, data: data, completion: completion)
	}

	func retrieveCurrentUser(completion: @Sendable @escaping (_ error: Error?) -> ()) {
		UserService.shared.retrieveCurrentUser(completion: completion)
	}

	// MARK: - Block User Functions

	func retrieveBlockedUsers(completion: @Sendable @escaping ([String]) -> ()) {
		UserService.shared.retrieveBlockedUsers(completion: completion)
	}

	func addBlockedUser(username: String, completion: @Sendable @escaping (Error?) -> Void) {
		UserService.shared.addBlockedUser(username: username, completion: completion)
	}

	func unblockUsers(username: String, completion: @Sendable @escaping (Error?) -> Void) {
		UserService.shared.unblockUsers(username: username, completion: completion)
	}

	// MARK: - Comment Functions

	func submitReply(postId: String, comment: String, advice: Advice, completion: @Sendable @escaping (Error?) -> Void) {
		CommentService.shared.submitReply(postId: postId, comment: comment, advice: advice, completion: completion)
	}

	func submitReplyToReply(postId: String, comment: String, advice: Advice, reply: Reply, completion: @Sendable @escaping (Error?) -> Void) {
		CommentService.shared.submitReplyToReply(postId: postId, comment: comment, advice: advice, reply: reply, completion: completion)
	}

	func submitAdvice(postId: String, comment: String) -> Any? {
		return CommentService.shared.submitAdvice(postId: postId, comment: comment)
	}

	func incrementAdviceCommentCount(postId: String, adviceId: String, completion: @Sendable @escaping () -> Void) {
		CommentService.shared.incrementAdviceCommentCount(postId: postId, adviceId: adviceId, completion: completion)
	}

	func incrementReplyCount(postId: String) {
		CommentService.shared.incrementReplyCount(postId: postId)
	}

	func setVoters(postId: String, adviceId: String, upVoters: [String], downVoters: [String], completion: @Sendable @escaping (Error?) -> Void) {
		CommentService.shared.setVoters(postId: postId, adviceId: adviceId, upVoters: upVoters, downVoters: downVoters, completion: completion)
	}

	// MARK: - Media Functions

	func retrieveMediaList(location: LocationReport, completion: @Sendable @escaping ([String]) -> ()) {
		MediaService.shared.retrieveMediaList(location: location, completion: completion)
	}

	func retrieveMediaLists(locations: [LocationReport], completion: @Sendable @escaping ([String: [String]]) -> ()) {
		MediaService.shared.retrieveMediaLists(locations: locations, completion: completion)
	}

	func insertNoMediaChild(reference: DatabaseReference, completion: @Sendable @escaping () -> ()) {
		MediaService.shared.insertNoMediaChild(reference: reference, completion: completion)
	}

	func addMediaToReference(reference: DatabaseReference, media: String, completion: @Sendable @escaping () -> ()) {
		MediaService.shared.addMediaToReference(reference: reference, media: media, completion: completion)
	}
}
