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
		guard let report = report else { return }
		let newText = txtViewReport.text
		if  newText != report.descriptionMessage
		{
			guard let text = newText, text.count >= 20 else {
				AlertController.showAlert(self, title: "Minimum Length Not Met", message: "The description message is to short, please enter more details.")
				return
			}
			let fireDatabaseService = FireDatabaseService()
			fireDatabaseService.setReportDescription(reportID: report.postId, description: text)
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
		}
		guard let spinner = spinnerView else { return }
		self.addChild(spinner)
		spinner.view.frame = self.view.frame
		self.view.addSubview(spinner.view)
		spinner.didMove(toParent: self)
	}

	func removeSpinner()
	{
		if spinnerView != nil
		{
			spinnerView?.willMove(toParent: nil)
			spinnerView?.view.removeFromSuperview()
			spinnerView?.removeFromParent()
			spinnerView = nil
		}
	}
	
	func updateVideos()
	{
		createSpinner()
		if let picView = picView, let report = report
		{
			if picView.selectedAssets.count > 0
			{
				let ref = FireDatabaseService.shared.incidentReference.child(report.postId)
				let fireStorage = FireStorage()
				fireStorage.UploadSelectedPhotos(reference: ref, pickerController: picView, completion: { [weak self] error in
					Task { @MainActor in
						guard let self = self else { return }
						if error == nil {
							self.removeSpinner()
							self.picView?.deselectAll()
							AlertController.showAlert(self, title: "Video Upload Successful", message: "Video Upload Complete!")
						} else {
							self.removeSpinner()
							AlertController.showAlert(self, title: "Video Upload Error", message: "Video Upload was not successful, please try again.")
						}
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
