//
//  StoryViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/24/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
import DKImagePickerController
import Firebase
import Photos

class StoryViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var storyTextView: UITextView!
    
	@IBOutlet weak var txtTitle: UITextField!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        self.registerHideKeyboardTappAround()
        storyTextView.addDoneButton(title: "Done", target: self, selector: #selector(DoneTap(sender:)))
		storyTextView.delegate = self
    }
    
    @objc func DoneTap(sender: Any)
    {
        view.endEditing(true)
    }
	
	
	func textViewDidEndEditing(_ textView: UITextView) {
		animateViewMoving(up: false, moveValue: 150)
	}
	
	func textViewDidBeginEditing(_ textView: UITextView) {
		animateViewMoving(up: true, moveValue: 150)
	}

	// Lifting the view up
	func animateViewMoving (up:Bool, moveValue :CGFloat){
		let movementDuration:TimeInterval = 0.3
		let movement:CGFloat = ( up ? -moveValue : moveValue)
		UIView.beginAnimations( "animateView", context: nil)
		UIView.setAnimationBeginsFromCurrentState(true)
		UIView.setAnimationDuration(movementDuration )
		self.parent!.view.frame = self.parent!.view.frame.offsetBy(dx: 0, dy: movement)
		UIView.commitAnimations()
	}
}
