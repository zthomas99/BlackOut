import Foundation
@preconcurrency import Firebase
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore

protocol ReportServicing {
	func setReportDescription(reportID: String, description: String)
	func retrieveReports(withUser user: String, completion: @Sendable @escaping ([IncidentReport]) -> ())
	func retrieveCommentMetadata(withReports reports: [IncidentReport], completion: @Sendable @escaping ([String: CommentMetadata]) -> ())
}

final class ReportService: ReportServicing, @unchecked Sendable {
	static let shared = ReportService()
	private let db = Firestore.firestore()
	private let incidentReference: DatabaseReference
	private let commentReference: CollectionReference

	private final class Box<T>: @unchecked Sendable {
		var value: T
		init(_ value: T) { self.value = value }
	}

	private init() {
		incidentReference = Database.database().reference().child("incidents")
		commentReference = db.collection("comments")
	}

	func setReportDescription(reportID: String, description: String) {
		incidentReference.child(reportID).updateChildValues(["descriptionMessage": description])
	}

	func retrieveReports(withUser user: String, completion: @Sendable @escaping ([IncidentReport]) -> ()) {
		var reports = [IncidentReport]()
		incidentReference.queryOrdered(byChild: "username").queryEqual(toValue: user).observeSingleEvent(of: .value, with: { snapshot in
			if snapshot.exists() {
				guard let snapConverter = SnapToReports(with: snapshot) else {
					print("Failed to convert snapshot to incident reports for user : \(user)")
					completion(reports)
					return
				}
				reports = snapConverter.reports
				completion(reports)
			}
		})
	}

	func retrieveCommentMetadata(withReports reports: [IncidentReport], completion: @Sendable @escaping ([String: CommentMetadata]) -> ()) {
		let state = Box((count: 0, map: [String: CommentMetadata]()))
		for report in reports {
			commentReference.document(report.postId).getDocument { snapshot, error in
				if error != nil {
					print("Failed to retrive document for report with id \(report.postId)")
				} else {
					let adviceCount = snapshot?.data()?["adviceCount"] as? Int ?? 0
					let commentCount = snapshot?.data()?["commentCount"] as? Int ?? 0
					state.value.count += 1
					state.value.map[report.postId] = CommentMetadata(adviceCount: adviceCount, commentCount: commentCount)
					if state.value.count == reports.count {
						completion(state.value.map)
					}
				}
			}
		}
	}
}
