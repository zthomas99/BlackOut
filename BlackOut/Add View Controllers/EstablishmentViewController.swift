//
//  EstablishmentViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/11/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit
import GooglePlaces

class EstablishmentViewController: UIViewController,GMSAutocompleteTableDataSourceDelegate, UITextFieldDelegate, UIViewControllerTransitioningDelegate, UITableViewDelegate {

	var tabledataSource: GMSAutocompleteTableDataSource?
	
	@IBOutlet weak var resultsTableView: UITableView!
	var businessCity:String?
	var businessState: String?
	var businessZip: String?
	var businessName:String?
	
	var delegate : EstablishmentControllerDelegate?
	var presentTransition : UIViewControllerAnimatedTransitioning?
	var dismissTransistion: UIViewControllerAnimatedTransitioning?
	
	@IBOutlet weak var businessLocationText: UITextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		tabledataSource = GMSAutocompleteTableDataSource()
		tabledataSource?.delegate = self
		resultsTableView.delegate = self
		resultsTableView.dataSource = tabledataSource
		
		if(traitCollection.userInterfaceStyle == .dark)
		{
			tabledataSource?.tableCellSeparatorColor = UIColor.yellow
			tabledataSource?.tableCellBackgroundColor = UIColor.darkGray
			tabledataSource?.primaryTextColor = UIColor.white
			tabledataSource?.secondaryTextColor = UIColor.lightText
		}
		presentTransition = RightToLeftTransition()
		dismissTransistion = LeftToRightTransition()
		
		let filter = GMSAutocompleteFilter()
		filter.country = "US"
		filter.type = .establishment
		tabledataSource?.autocompleteFilter = filter
		
		businessLocationText.dropShadow(color: .black)
		businessLocationText.delegate = self
		businessLocationText.becomeFirstResponder()
		
		resultsTableView?.backgroundColor = UIColor.darkGray
		resultsTableView?.register(UITableViewCell.self, forCellReuseIdentifier: "radiusCell")
		resultsTableView?.separatorInset = .zero
		resultsTableView?.tableFooterView = UIView()
		resultsTableView?.tableFooterView?.backgroundColor = UIColor.lightGray
	}
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(true)
	}
	
	func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource)
    {
        resultsTableView?.reloadData()
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        businessLocationText.text = prediction.attributedFullText.string
        businessName = prediction.attributedPrimaryText.string
        let cityArray: [String] = prediction.attributedSecondaryText!.string.components(separatedBy: ",")
        if(cityArray.count == 4)
        {
            businessCity = cityArray[1].trimmingCharacters(in: .whitespaces) + "," + cityArray[2] + "," + cityArray[3]
        }
        else
        {
            businessCity = prediction.attributedSecondaryText!.string
        }
        return true
    }
    
	@IBAction func TextDidChange(_ sender: Any) {
		tabledataSource?.sourceTextHasChanged(businessLocationText.text)
	}
	
	
	func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        for components in place.addressComponents!
        {
            for types in components.types
            {
                if(types == "administrative_area_level_1")
                {
                    businessState = components.name
                }
                if(types == "postal_code")
                {
                    businessZip = components.name
                }
                if(businessZip != nil && businessState != nil)
                {
                    break
                }
            }
        }
		
		BackToAddSearchViewController()
    }
    
	func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
		resultsTableView.reloadData()
	}
	
	func BackToAddSearchViewController()
	{
		delegate?.sendEstablishmentInfo(location: businessLocationText.text ?? "", city: businessCity!, state: businessState!, zip: businessZip!, name: businessName!)
		self.view.endEditing(true)
		self.dismiss(animated: true, completion: nil)
	}
	
	func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        AlertController.showAlert(self, title: "Auto Complete Error", message: error.localizedDescription)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tabledataSource?.tableView(tableView, didSelectRowAt: indexPath)
    }

	@IBAction func CancelButtonWasTapped(_ sender: Any) {
		self.view.endEditing(true)
		self.dismiss(animated: true, completion: nil)
	}

}

protocol EstablishmentControllerDelegate{
	func sendEstablishmentInfo(location:String, city:String, state:String, zip:String, name:String)
}
