//
//  AddSearchViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/24/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
import GooglePlaces
import CoreLocation

class AddSearchViewController: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate, EstablishmentControllerDelegate
{
	
	
    var businessCity:String?
    var businessState: String?
    var businessZip: String?
    var businessName:String?
    
    @IBOutlet weak var businessLocationText: UITextField!
	
	var estViewController: EstablishmentViewController?
	var presentTransition: UIViewControllerAnimatedTransitioning?
	var dismissTransition: UIViewControllerAnimatedTransitioning?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerHideKeyboardTappAround()
		businessLocationText.delegate = self
		businessLocationText.layer.cornerRadius = 15.0
		businessLocationText.layer.masksToBounds = true
		presentTransition = RightToLeftTransition()
		dismissTransition = LeftToRightTransition()
		let startPoint = CGPoint(x: 0.5,y: 0.3)
		let endPoint = CGPoint(x: 0.5, y: 1.0)
		let boGold = UIColor(displayP3Red: 254.0/255.0, green: 208.0/255.0, blue: 28.0/255.0, alpha: 1.0)
		self.view.layerGradient(primaryColor: UIColor.black.cgColor, secondaryColor: boGold.cgColor, startPoint: startPoint, endPoint: endPoint)
    }

	
	@IBAction func TextEditingBegin(_ sender: Any) {
		//self.performSegue(withIdentifier: "AddToEstSearch", sender: nil)
		let storyBoard = UIStoryboard.init(name: "Navigation", bundle: nil)
		let estController = storyBoard.instantiateViewController(withIdentifier: "EstablishmentController") as? EstablishmentViewController
		estController?.delegate = self
		estController?.transitioningDelegate = self
		estController?.modalPresentationStyle = .fullScreen
		present(estController!, animated: true, completion: nil)
	}
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if(segue.identifier == "AddToEstSearch")
		{
			estViewController = segue.destination as? EstablishmentViewController
			
		}
	}
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return presentTransition
	}
	
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return dismissTransition
	}
	
	func sendEstablishmentInfo(location: String, city: String, state: String, zip: String, name: String) {
		businessLocationText.text = location
		businessCity = city
		businessState = state
		businessZip = zip
		businessName = name
	}
}

