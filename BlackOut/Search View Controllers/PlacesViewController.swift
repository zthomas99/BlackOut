//
//  PlacesViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/10/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
	@IBOutlet weak var searchText: UITextField!
	@IBOutlet weak var resultsTable: UITableView!

	var delegate: PlacesViewControllerDelegate?

	private let placesClient = GMSPlacesClient.shared()
	private var suggestions: [GMSAutocompleteSuggestion] = []
	private var sessionToken = GMSAutocompleteSessionToken()
	private var stateShortName: String = ""
	private var location: String = ""

	var presentTransition: UIViewControllerAnimatedTransitioning?
	var dismissTransition: UIViewControllerAnimatedTransitioning?

    override func viewDidLoad() {
        super.viewDidLoad()

		resultsTable.backgroundColor = UIColor.darkGray
        resultsTable.dataSource = self
        resultsTable.delegate = self

		resultsTable.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
		resultsTable.separatorInset = .zero
		resultsTable.tableFooterView = UIView()
		resultsTable.tableFooterView?.backgroundColor = UIColor.lightGray

		presentTransition = RightToLeftTransition()
		dismissTransition = LeftToRightTransition()

        searchText.delegate = self
		searchText.dropShadow(color: .black)
		searchText.becomeFirstResponder()
    }

	// MARK: - Autocomplete

	@IBAction func SearchTextChanged(_ sender: Any) {
		guard let query = searchText.text, !query.isEmpty else {
			suggestions.removeAll()
			resultsTable.reloadData()
			return
		}

		let filter = GMSAutocompleteFilter()
		filter.types = ["(regions)"]
		filter.countries = ["US"]

		let request = GMSAutocompleteRequest(query: query)
		request.filter = filter
		request.sessionToken = sessionToken

		placesClient.fetchAutocompleteSuggestions(from: request) { [weak self] results, error in
			guard let self = self else { return }
			if let error = error {
				print("Autocomplete error: \(error.localizedDescription)")
				return
			}
			self.suggestions = results ?? []
			self.resultsTable.reloadData()
		}
	}

	// MARK: - UITableViewDataSource

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return suggestions.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
		if let placeSuggestion = suggestions[indexPath.row].placeSuggestion {
			cell.textLabel?.attributedText = placeSuggestion.attributedFullText
		}
		cell.backgroundColor = UIColor.darkGray
		cell.textLabel?.textColor = .white
		return cell
	}

	// MARK: - UITableViewDelegate

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let placeSuggestion = suggestions[indexPath.row].placeSuggestion else { return }

		searchText.text = placeSuggestion.attributedFullText.string
		location = placeSuggestion.attributedFullText.string
		view.endEditing(true)

		fetchPlaceDetails(placeID: placeSuggestion.placeID)
    }

	private func fetchPlaceDetails(placeID: String) {
		let placeProperties = [GMSPlaceProperty.addressComponents.rawValue]
		let request = GMSFetchPlaceRequest(placeID: placeID, placeProperties: placeProperties, sessionToken: sessionToken)

		placesClient.fetchPlace(with: request) { [weak self] place, error in
			guard let self = self else { return }
			if let error = error {
				AlertController.showAlert(self, title: "Google Places Error", message: error.localizedDescription)
				return
			}
			if let components = place?.addressComponents {
				for component in components {
					for type in component.types {
						if type == "administrative_area_level_1" {
							self.stateShortName = component.shortName ?? component.name
						}
					}
				}
			}
			self.sessionToken = GMSAutocompleteSessionToken()
			self.backToSearchViewController()
		}
	}

	private func backToSearchViewController() {
		delegate?.sendSearchInfo(place: location, state: stateShortName)
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: - UITextFieldDelegate

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		view.endEditing(true)
		return true
	}

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return presentTransition
	}

	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return dismissTransition
	}

	@IBAction func CancelButtonWasTapped(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

}

@MainActor protocol PlacesViewControllerDelegate {
	func sendSearchInfo(place: String, state: String)
}
