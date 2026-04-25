//
//  EstablishmentViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/11/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit
import GooglePlaces

class EstablishmentViewController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate, UITableViewDelegate, UITableViewDataSource {

	private let placesClient = GMSPlacesClient.shared()
	private var suggestions: [GMSAutocompleteSuggestion] = []
	private var sessionToken = GMSAutocompleteSessionToken()

	@IBOutlet weak var resultsTableView: UITableView!
	var businessCity: String?
	var businessState: String?
	var businessZip: String?
	var businessName: String?

	var delegate: EstablishmentControllerDelegate?
	var presentTransition: UIViewControllerAnimatedTransitioning?
	var dismissTransistion: UIViewControllerAnimatedTransitioning?

	@IBOutlet weak var businessLocationText: UITextField!

	override func viewDidLoad() {
        super.viewDidLoad()
		resultsTableView.delegate = self
		resultsTableView.dataSource = self

		presentTransition = RightToLeftTransition()
		dismissTransistion = LeftToRightTransition()

		businessLocationText.dropShadow(color: .black)
		businessLocationText.delegate = self
		businessLocationText.becomeFirstResponder()

		resultsTableView.backgroundColor = UIColor.darkGray
		resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
		resultsTableView.separatorInset = .zero
		resultsTableView.tableFooterView = UIView()
		resultsTableView.tableFooterView?.backgroundColor = UIColor.lightGray
	}

	// MARK: - Autocomplete

	@IBAction func TextDidChange(_ sender: Any) {
		guard let query = businessLocationText.text, !query.isEmpty else {
			suggestions.removeAll()
			resultsTableView.reloadData()
			return
		}

		let filter = GMSAutocompleteFilter()
		filter.countries = ["US"]
		filter.types = ["establishment"]

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
			self.resultsTableView.reloadData()
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
			cell.detailTextLabel?.attributedText = placeSuggestion.attributedSecondaryText
		}
		cell.backgroundColor = UIColor.darkGray
		cell.textLabel?.textColor = .white
		cell.detailTextLabel?.textColor = .lightText
		return cell
	}

	// MARK: - UITableViewDelegate

	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 50.0
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let placeSuggestion = suggestions[indexPath.row].placeSuggestion else { return }

		businessLocationText.text = placeSuggestion.attributedFullText.string
		businessName = placeSuggestion.attributedPrimaryText.string

		if let secondary = placeSuggestion.attributedSecondaryText?.string {
			let cityArray = secondary.components(separatedBy: ",")
			if cityArray.count == 4 {
				businessCity = cityArray[1].trimmingCharacters(in: .whitespaces) + "," + cityArray[2] + "," + cityArray[3]
			} else {
				businessCity = secondary
			}
		}

		view.endEditing(true)
		fetchPlaceDetails(placeID: placeSuggestion.placeID)
	}

	private func fetchPlaceDetails(placeID: String) {
		let placeProperties = [GMSPlaceProperty.addressComponents.rawValue]
		let request = GMSFetchPlaceRequest(placeID: placeID, placeProperties: placeProperties, sessionToken: sessionToken)

		placesClient.fetchPlace(with: request) { [weak self] place, error in
			guard let self = self else { return }
			if let error = error {
				print("Fetch place error: \(error.localizedDescription)")
				self.backToAddSearchViewController()
				return
			}
			guard let place = place, let components = place.addressComponents else {
				self.backToAddSearchViewController()
				return
			}
			for component in components {
				for type in component.types {
					if type == "administrative_area_level_1" {
						self.businessState = component.name
					}
					if type == "postal_code" {
						self.businessZip = component.name
					}
				}
			}
			// Start a new session for the next search
			self.sessionToken = GMSAutocompleteSessionToken()
			self.backToAddSearchViewController()
		}
	}

	private func backToAddSearchViewController() {
		delegate?.sendEstablishmentInfo(
			location: businessLocationText.text ?? "",
			city: businessCity ?? "",
			state: businessState ?? "",
			zip: businessZip ?? "",
			name: businessName ?? ""
		)
		self.view.endEditing(true)
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
		return dismissTransistion
	}

	@IBAction func CancelButtonWasTapped(_ sender: Any) {
		self.view.endEditing(true)
		self.dismiss(animated: true, completion: nil)
	}

}

@MainActor protocol EstablishmentControllerDelegate {
	func sendEstablishmentInfo(location: String, city: String, state: String, zip: String, name: String)
}
