import Foundation
@preconcurrency import Firebase
@preconcurrency import FirebaseCore
@preconcurrency import FirebaseFirestore

protocol MediaServicing {
	func retrieveMediaList(location: LocationReport, completion: @Sendable @escaping ([String]) -> ())
	func retrieveMediaLists(locations: [LocationReport], completion: @Sendable @escaping ([String: [String]]) -> ())
	func insertNoMediaChild(reference: DatabaseReference, completion: @Sendable @escaping () -> ())
	func addMediaToReference(reference: DatabaseReference, media: String, completion: @Sendable @escaping () -> ())
}

final class MediaService: MediaServicing, @unchecked Sendable {
	static let shared = MediaService()
	private let db = Firestore.firestore()
	private let locationReference: CollectionReference

	private final class Box<T>: @unchecked Sendable {
		var value: T
		init(_ value: T) { self.value = value }
	}

	private init() {
		locationReference = db.collection("locations")
	}

	func retrieveMediaList(location: LocationReport, completion: @Sendable @escaping ([String]) -> ()) {
		let state = Box((counter: 0, list: [String]()))
		let reportCount = location.incidentReports.count
		for report in location.incidentReports {
			let reportRef = locationReference.document(location.postId).collection("reports").document(report)
			reportRef.getDocument { snapshot, err in
				if let err = err {
					state.value.counter += 1
					print("There was an error in querying the documents for the following post id  : \(location.postId) error : \(err)")
					if reportCount == state.value.counter {
						completion(state.value.list)
					}
				} else {
					if let snapshot = snapshot, snapshot.exists,
					   let mediaArry = snapshot.data()?["media"] as? [String: [String]] {
						for media in mediaArry.values {
							if let first = media.first {
								state.value.list.append(first)
							}
						}
						state.value.counter += 1
						if reportCount == state.value.counter {
							completion(state.value.list)
						}
					} else {
						state.value.counter += 1
						if reportCount == state.value.counter {
							completion(state.value.list)
						}
					}
				}
			}
		}
	}

	func retrieveMediaLists(locations: [LocationReport], completion: @Sendable @escaping ([String: [String]]) -> ()) {
		let locationCount = locations.count
		let outerState = Box((locationCounter: 0, mediaList: [String: [String]]()))
		for location in locations {
			if location.hasMediaFiles {
				let reportCount = location.incidentReports.count
				let reportState = Box(0)
				for report in location.incidentReports {
					let reportRef = locationReference.document(location.postId).collection("reports").document(report)
					reportRef.getDocument { snapshot, err in
						if let err = err {
							reportState.value += 1
							if reportState.value == reportCount {
								outerState.value.locationCounter += 1
							}
							print("There was an error in querying the documents for the following post id  : \(location.postId) error : \(err)")
							if outerState.value.locationCounter == locationCount {
								completion(outerState.value.mediaList)
							}
						} else {
							if let snapshot = snapshot, snapshot.exists,
							   let mediaArry = snapshot.data()?["media"] as? [String: [String]] {
								var fileList = [String]()
								for media in mediaArry.values {
									if let first = media.first {
										fileList.append(first)
									}
								}
								outerState.value.mediaList[location.postId] = fileList
								reportState.value += 1
								if reportCount == reportState.value {
									outerState.value.locationCounter += 1
								}
								if outerState.value.locationCounter == locationCount {
									completion(outerState.value.mediaList)
								}
							}
						}
					}
				}
			} else {
				outerState.value.locationCounter += 1
				if outerState.value.locationCounter == locationCount {
					completion(outerState.value.mediaList)
				}
			}
		}
	}

	func insertNoMediaChild(reference: DatabaseReference, completion: @Sendable @escaping () -> ()) {
		let noMediaParam = ["NoMedia": true]
		reference.setValue(noMediaParam) { error, ref in
			if error != nil {
				print("Failed to set no media reference for the following reasons: \(String(describing: error))")
			} else {
				completion()
			}
		}
	}

	func addMediaToReference(reference: DatabaseReference, media: String, completion: @Sendable @escaping () -> ()) {
		reference.child("incidentMedia").childByAutoId().observeSingleEvent(of: .value, with: { snapshot in
			if snapshot.exists(), let mediaArr = snapshot.value as? [String] {
				var newMediaArr: [String] = []
				newMediaArr.append(contentsOf: mediaArr)
				newMediaArr.append(media)
				if newMediaArr[0] == " " {
					newMediaArr.remove(at: 0)
				}
				reference.child("incidentMedia").childByAutoId().setValue(newMediaArr) { error, ref in
					if error != nil {
						print("Failed to set media reference for the following media item \(media)")
					} else {
						completion()
					}
				}
			} else {
				var newMediaArr: [String] = []
				newMediaArr.append(media)
				reference.child("incidentMedia").childByAutoId().setValue(newMediaArr) { error, ref in
					if error != nil {
						print("Failed to set media reference for the following media item \(media) : error - \(String(describing: error))")
					} else {
						completion()
					}
				}
			}
		})
	}
}
