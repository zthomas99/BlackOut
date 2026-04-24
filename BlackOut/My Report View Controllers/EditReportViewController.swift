//
//  EditReportViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/21/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class EditReportViewController: UIViewController, UITextViewDelegate {
	var picView : DKPickViewController?
	var report :IncidentReport?
	var spinnerView : SpinnerViewController?
	
	@IBOutlet weak var lblReportTitle: UILabel!
	@IBOutlet weak var txtViewReport: UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		txtViewReport.text = report?.descriptionMessage
		txtViewReport.addDoneButton(title: "Done", target: self, selector: #selector(DoneTap(sender:)))
		lblReportTitle.text = report?.reportTitle.uppercased()
		txtViewReport.becomeFirstResponder()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "EmbedPickView"
		{
			picView = segue.destination as? DKPickViewController
			picView?.sourceType = .photo
			
		}
	}

	@IBAction func SendButtonWasTapped(_ sender: Any) {
		editDescription()
		updateVideos()
	}
	
	func editDescription()
	{
		let newText = txtViewReport.text
		if  newText != report!.descriptionMessage
		{
			if newText!.count < 20
			{
				AlertController.showAlert(self, title: "Minimum Length Not Met", message: "The description message is to short, please enter more details.")
			}
			else
			{
				let fireDatabaseService = FireDatabaseService()
				fireDatabaseService.SetReportDescription(reportID: report!.postId, description: txtViewReport.text)
			}
		}
	}
	
	@objc func DoneTap(sender: Any)
	{
		view.endEditing(true)
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
	
	func updateVideos()
	{
		createSpinner()
		if picView != nil
		{
			if (picView?.selectedAssets.count)! > 0
			{
				let ref = FireDatabaseService.shared.incidentReference.child(report!.postId)
				let fireStorage = FireStorage()
				fireStorage.UploadSelectedPhotos(reference: ref, pickerController: picView!, completion: {
					(error)
					in
					if error == nil
					{
						self.removeSpinner()
						self.picView?.deselectAll()
						AlertController.showAlert(self, title: "Video Upload Successful", message: "Video Upload Complete!")
					}
					else
					{
						self.removeSpinner()
						AlertController.showAlert(self, title: "Video Upload Error", message: "Video Upload was not successful, please try again.")
					}
				})
			}
			else
			{
				removeSpinner()
			}
		}
	}
	
	@IBAction func CancelButtonWasTapped(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
//MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
}
