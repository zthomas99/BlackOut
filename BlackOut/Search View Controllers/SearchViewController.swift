//
//  SearchViewController.swift
//  BlackOut
//
//  Created by Zacch Thomas on 9/29/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces

class SearchViewController:UIViewController, UITableViewDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate, PlacesViewControllerDelegate{
	
    @IBOutlet weak var searchContainer: UIView!
    @IBOutlet weak var searchText: UITextField!
    var coordinator: SearchCoordinating = SearchCoordinator.shared

	var presentTransition: UIViewControllerAnimatedTransitioning?
	var dismissTransition: UIViewControllerAnimatedTransitioning?
	
    var locationTableViewController:LocationTableViewController?
	var placesViewController : PlacesViewController?
	
	let searchFunctions = LocationSearch()
	
    //Fire Database field
    var database:FireDatabaseService?
    
    var reports = [IncidentReport]()
    var stateShortName : String = ""
	var borderHeight : CGFloat = 0.20
	
    override func viewDidLoad()
    {
        super.viewDidLoad()
        searchText.delegate = self
		presentTransition = RightToLeftTransition()
		dismissTransition = LeftToRightTransition()
		searchText.layer.masksToBounds = true
		searchText.layer.borderColor = UIColor(displayP3Red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6).cgColor
		searchText.layer.borderWidth	= 0.5
		
		let borderFrame = CGRect(x: 0, y: searchContainer.frame.size.height - borderHeight, width: self.view.frame.width, height: borderHeight)
		let searchBorder = CALayer()
		searchBorder.frame = borderFrame
		searchBorder.backgroundColor = UIColor.white.cgColor
		searchBorder.opacity = 0.3
		searchContainer.layer.addSublayer(searchBorder)
		
    }
    
    @IBAction func CitySearchWasTapped(_ sender: Any)
    {
		coordinator.presentPlaces(from: self, searchText: searchText, delegate: self, transitioningDelegate: self)
    }
    
   func Search()
    {
		let searchType = searchFunctions.searchType(searchText: searchText.text!)
        switch(searchType)
        {
        case "city" :
			let search = searchFunctions.formatCitySearch(searchText: searchText.text!, stateShortName: stateShortName)
			FireDatabaseService.shared.retrieveLocations(search: search, searchType: searchType, completion: { [weak self] locations in
				Task { @MainActor in
					self?.locationTableViewController?.locations = locations
					self?.locationTableViewController?.isFirstSearch = false
					self?.locationTableViewController?.downloadReports()
				}
			})
        case "state" :
			let search = searchFunctions.formaatStateSearch(searchText: searchText.text!)
			FireDatabaseService.shared.retrieveLocations(search: search, searchType: searchType, completion: { [weak self] locations in
				Task { @MainActor in
					self?.locationTableViewController?.locations = locations
					self?.locationTableViewController?.isFirstSearch = false
					self?.locationTableViewController?.downloadReports()
				}
			})
         case "zipCode" :
		   let search = searchFunctions.formatZipSearch(searchText: searchText.text!, stateShortName: stateShortName)
		   FireDatabaseService.shared.retrieveLocations(search: search, searchType: searchType, completion: { [weak self] locations in
			Task { @MainActor in
				self?.locationTableViewController?.locations = locations
				self?.locationTableViewController?.isFirstSearch = false
				self?.locationTableViewController?.downloadReports()
			}
		})
        case "invalid" :
            AlertController.showAlert(self, title: "Invalid Search", message: "The entry is an invalid search. \nPlease enter a zip code or city and select one of the returned options in view")
        default :
            AlertController.showAlert(self, title: "Invalid Search", message: "The entry is an invalid search. \nPlease enter a zip code or city and select one of the returned options in view")
            
        }
		
    }
    
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let sepeartorFrame = CGRect(x: 0, y: searchContainer.bounds.maxY, width: self.view.frame.width, height: 2.0)
		let separator = UIView(frame: sepeartorFrame)
		separator.backgroundColor = UIColor.white
		searchContainer.addSubview(separator)
	}
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "SearchToLocations")
        {
            locationTableViewController = segue.destination as? LocationTableViewController
        }
    }

	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
	{
		return presentTransition
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return dismissTransition
	}
	
    //MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
	func sendSearchInfo(place: String, state: String) {
		stateShortName = state
		searchText.text = place
		Search()
	}
}
