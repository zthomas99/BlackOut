//
//  AddTableViewController.swift
//  BlackOut
//
//  Created by Zacch Thomas on 10/7/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import Photos
import Firebase

class AddViewController: UIViewController {
    
    @IBOutlet weak var businessPhotoContainerView: UIView!
    @IBOutlet weak var EstSearchContainerView: UIView!
    @IBOutlet weak var mediaSelectContainerView: UIView!
    @IBOutlet weak var storyContainerView: UIView!
    
	@IBOutlet weak var segmentControlContainer: UIView!
	var businessPhotoController : BusinessPhotoViewController!
    var establishSearchController : AddSearchViewController!
    var mediaSelectController : MediaSelectViewController!
    var storyController : StoryViewController!
	var spinnerView : SpinnerViewController?
	
    //MARK: - View Did Load
    override func viewDidLoad()
    {
        super.viewDidLoad()
		
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ToBusinessPhoto")
        {
            businessPhotoController = segue.destination as? BusinessPhotoViewController
        }
        else if (segue.identifier == "ToAddSearch")
        {
            establishSearchController = segue.destination as? AddSearchViewController
			
        }
        else if(segue.identifier == "ToMediaSelect")
        {
            mediaSelectController = segue.destination as? MediaSelectViewController
        }
        else if(segue.identifier == "ToStory")
        {
            storyController = segue.destination as? StoryViewController
        }
    }
    
    @IBAction func SegementValueChanged(_ sender: AddSegmentControl)
    {
        if sender.selectedIndex == 0
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.businessPhotoContainerView.alpha = 1
                self.EstSearchContainerView.alpha = 0
                self.mediaSelectContainerView.alpha = 0
                self.storyContainerView.alpha = 0
            })
        }
        else if sender.selectedIndex == 1
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.businessPhotoContainerView.alpha = 0
                self.EstSearchContainerView.alpha = 1
                self.mediaSelectContainerView.alpha = 0
                self.storyContainerView.alpha = 0
            })
        }
        else if sender.selectedIndex == 2
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.businessPhotoContainerView.alpha = 0
                self.EstSearchContainerView.alpha = 0
                self.mediaSelectContainerView.alpha = 1
                self.storyContainerView.alpha = 0
            })
        }
        else if sender.selectedIndex == 3
        {
            UIView.animate(withDuration: 0.5, animations: {
                self.businessPhotoContainerView.alpha = 0
                self.EstSearchContainerView.alpha = 0
                self.mediaSelectContainerView.alpha = 0
                self.storyContainerView.alpha = 1
            })
        }
    }
    
    /**
            Cloud functions handle adding location entries to the Firesstore database.
            Ther creation of NoMedia Child  and  IncidentMedia children in the Firebase database halndles adding
            location entries to the Firestore.
     */
    @IBAction func UploadButtonTapped(_ sender: UIButton)
    {
		sender.preventRepeatedPresses(inNext: 1)
        if(storyController?.storyTextView.text == nil || storyController?.storyTextView.text == "")
        {
            AlertController.showAlert(self, title: "Missing Entry", message: "Please enter a description of what happen.")
            return
        }
        
		if((storyController?.storyTextView.text.count)! < 20)
		{
			AlertController.showAlert(self, title: "Short Message", message: "Story has to be at least 20 characters long.")
			return
		}
		
		if((storyController?.txtTitle.text == "") || storyController?.txtTitle.text == nil)
		{
			AlertController.showAlert(self, title: "Missing Title", message: "Please enter a title for your report.")
			return
		}
		
		if((storyController?.txtTitle.text!.count)! < 5)
		{
			AlertController.showAlert(self, title: "Short Title", message: "Title has to be at least 5 characters long.")
			return
		}
		
        if(establishSearchController?.businessLocationText.text == nil || establishSearchController?.businessLocationText.text == "")
        {
            AlertController.showAlert(self, title: "Missing Entry", message: "Please enter a location of the establishment in the 'Est.' view .")
            return
        }
        var businessPhotoFileName = "default.JPG"
        
        if(businessPhotoController?.businessImage != nil)
        {
            let identifier = NSUUID.init().uuidString
            businessPhotoFileName = identifier + ".JPG"
            let imageData = UIImageJPEGRepresentation(businessPhotoController.businessImage!, 1)
            let uploadBusinessPhotoRef = FireStorage.init().mediaReference.child(businessPhotoFileName)
            DispatchQueue.main.async
                {
                    let uploadTask = uploadBusinessPhotoRef.putData(imageData!, metadata: nil)
                    {
                        (metadata,error) in
                        print(error ?? "No Error")
                    }
                    uploadTask.resume()
            }
        }
        let referrence : DatabaseReference  = FireDatabaseService.shared.incidentReference.childByAutoId()
        let dateString = String(describing: Date())
        let currentUser = Auth.auth().currentUser?.displayName
        let replyCount = 0
        // create an asset count to determine which of the parameters is used to trigger the creation of the locations entry in Firestore
        let assetCount = mediaSelectController.pickerController?.selectedAssets.count
        var parameters : [String : Any]
        if(assetCount == 0)
        {
            parameters = ["username"           : currentUser!,
                          "businessName"       : establishSearchController?.businessName!,
                          "descriptionMessage" : storyController?.storyTextView.text!,
						  "reportTitle"        : storyController?.txtTitle.text!,
                          "businessLocation"   : establishSearchController?.businessLocationText!.text,
                          "businessPhoto"      : businessPhotoFileName,
						  "replyCount"         : replyCount,
                          "businessCity"       : establishSearchController?.businessCity!,
                          "NoMedia"            : true,
                          "state"              : establishSearchController?.businessState!,
                          "zipCode"            : establishSearchController?.businessZip!,
                          "date"               : dateString] as [String : Any]
        }
        else
        {
            //IncidentMedia child is only added to the Firebase entry after the media has been uploaded to the Firebase Storage.
            parameters = ["username"           : currentUser!,
                          "businessName"       : establishSearchController?.businessName!,
                          "descriptionMessage" : storyController?.storyTextView.text!,
						  "reportTitle"        : storyController?.txtTitle.text!,
                          "businessLocation"   : establishSearchController?.businessLocationText!.text,
						  "replyCount"         : replyCount,
                          "businessPhoto"      : businessPhotoFileName,
                          "businessCity"       : establishSearchController?.businessCity!,
                          "state"              : establishSearchController?.businessState!,
                          "zipCode"            : establishSearchController?.businessZip!,
                          "date"               : dateString] as [String : Any]
        }
		createSpinner()
		referrence.setValue(parameters, withCompletionBlock: {(error, ref) in
			if(error != nil)
			{
				self.removeSpinner()
				AlertController.showAlert(self, title: "Upload Failure", message: "The report failed to upload, please try again at another time.")
			}
			else
			{
				if (self.mediaSelectController.pickerController?.selectedAssets.count)! > 0
				{
					let fireStorage = FireStorage()
					fireStorage.UploadSelectedPhotos(reference: referrence, pickerController: self.mediaSelectController.pickerController! , completion: {
						(error)
						
						in
						if error != nil
						{
							self.removeSpinner()
							self.reset()
							AlertController.showAlert(self, title: "Media Upload Error", message: "Unable to upload selected media please try uploading the media through my reports.")
						}
						else
						{
							self.removeSpinner()
							self.reset()
							AlertController.showAlert(self, title: "Successful Upload", message: "The report was successfully uploaded. You can now search for the report under the 'Search' screen by city, state, or zip code.")
						}
					})
				}
				else
				{
					self.removeSpinner()
					self.reset()
					AlertController.showAlert(self, title: "Successful Upload", message: "The report was successfully uploaded. You can now search for the report under the 'Search' screen by city, state, or zip code.")
				}
			}
		})
    }
    
	func createSpinner()
	{
		if spinnerView == nil
		{
			spinnerView = SpinnerViewController()
			self.addChildViewController(spinnerView!)
			spinnerView!.view.frame = self.view.frame
			self.view.addSubview(spinnerView!.view)
			spinnerView?.didMove(toParentViewController: self)
		}
		else
		{
			self.addChildViewController(spinnerView!)
			spinnerView!.view.frame = self.view.frame
			self.view.addSubview(spinnerView!.view)
			spinnerView?.didMove(toParentViewController: self)
		}
	}
	
	func removeSpinner()
	{
		if spinnerView != nil
		{
			spinnerView?.willMove(toParentViewController: nil)
			spinnerView?.view.removeFromSuperview()
			spinnerView?.removeFromParentViewController()
			spinnerView = nil
		}
	}
	
    func reset()
    {   let defaultImage = UIImage(named: "establishment.png")
        businessPhotoController.defaultBusinessImageView.setImage(defaultImage, for: .normal)
		businessPhotoController?.businessImage = nil
        establishSearchController.businessLocationText.text = ""
        establishSearchController.businessZip = ""
        establishSearchController.businessCity = ""
        establishSearchController.businessName = ""
        establishSearchController.businessState = ""
        storyController.storyTextView.text = ""
		storyController.txtTitle.text = ""
    }
    
    //MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
}
