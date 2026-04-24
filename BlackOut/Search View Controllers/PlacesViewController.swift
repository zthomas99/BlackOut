//
//  PlacesViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/10/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit
import GooglePlaces

class PlacesViewController: UIViewController,UITableViewDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate, GMSAutocompleteTableDataSourceDelegate {
	@IBOutlet weak var searchText: UITextField!
	
	@IBOutlet weak var resultsTable: UITableView!
	
	var delegate : PlacesViewControllerDelegate?
	
	//GMS Table DataSource Variable
    var tableDataSource: GMSAutocompleteTableDataSource?
	var stateShortName : String = ""
	var location: String = ""
	
	var presentTransition : UIViewControllerAnimatedTransitioning?
	var dismissTransition : UIViewControllerAnimatedTransitioning?
	
    override func viewDidLoad() {
        super.viewDidLoad()

		let filter = GMSAutocompleteFilter()
			  
			  filter.type = .region
			  filter.country = "US"
		tableDataSource = GMSAutocompleteTableDataSource()
			   tableDataSource?.autocompleteFilter = filter
			   tableDataSource?.delegate = self
		
		if(traitCollection.userInterfaceStyle == .dark)
			   {
				   tableDataSource?.tableCellSeparatorColor = UIColor.yellow
				   tableDataSource?.tableCellBackgroundColor = UIColor.darkGray
				   tableDataSource?.primaryTextColor = UIColor.white
				   tableDataSource?.secondaryTextColor = UIColor.lightText
			   }
			   
		resultsTable?.backgroundColor = UIColor.darkGray
        resultsTable?.dataSource = tableDataSource
        resultsTable?.delegate = self
		
		resultsTable?.register(UITableViewCell.self, forCellReuseIdentifier: "radiusCell")
		resultsTable?.separatorInset = .zero
		resultsTable?.tableFooterView = UIView()
		resultsTable?.tableFooterView?.backgroundColor = UIColor.lightGray
		
		presentTransition = RightToLeftTransition()
		dismissTransition = LeftToRightTransition()
		
        searchText.delegate = self
		searchText.dropShadow(color: .black)
		searchText.becomeFirstResponder()
    }
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableDataSource?.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool
    {
        searchText.text = prediction.attributedFullText.string
		location = prediction.attributedFullText.string
        view.endEditing(true)
        return true
    }
	
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource)
    {
        resultsTable?.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource)
    {
        resultsTable?.reloadData()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace)
    {
        for components in place.addressComponents!
        {
            for types in components.types
            {
                if(types == "administrative_area_level_1")
                {
                    stateShortName = components.shortName!
                }
            }
        }
        resultsTable?.reloadData()
		BackToSearchViewController()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error)
    {
        AlertController.showAlert(self, title: "Google Places Error", message: error.localizedDescription)
    }
    
	@IBAction func SearchTextChanged(_ sender: Any) {
	tableDataSource?.sourceTextHasChanged(searchText.text)
	}
	
	//MARK: - UITextFieldDelegate Functions
	   func textFieldShouldReturn(_ textField: UITextField) -> Bool
	   {
		   view.endEditing(true)
		   return true
	   }

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return presentTransition
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return dismissTransition
	}
	
	func BackToSearchViewController()
	{
		delegate?.sendSearchInfo(place: location, state: stateShortName)
		self.dismiss(animated: true, completion: nil)
		
	}
	
	@IBAction func CancelButtonWasTapped(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}

protocol PlacesViewControllerDelegate  {
	func sendSearchInfo(place: String, state: String)
}
