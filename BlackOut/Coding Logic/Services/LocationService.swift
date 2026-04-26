import Foundation
@preconcurrency import Firebase
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore

protocol LocationServicing {
	func retrieveLocations(search: String, searchType: String, completion: @Sendable @escaping ([LocationReport]) -> ())
}

final class LocationService: LocationServicing, @unchecked Sendable {
	static let shared = LocationService()
	private let db = Firestore.firestore()
	private let locationReference: CollectionReference

	private init() {
		locationReference = db.collection("locations")
	}

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

		locationReference.whereField(field, isEqualTo: search)
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
}
