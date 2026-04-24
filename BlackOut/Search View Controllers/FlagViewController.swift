//
//  FlagViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/16/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FlagViewController: UIViewController{

    var quest: String!
    var incident: IncidentReport!
    
    @IBOutlet weak var flagDescription: UITextView!
    @IBOutlet weak var questionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = quest
        flagDescription.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sedner:)))
    }
    
    @IBAction func CancelWasTapped(_ sender: Any) {
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SubmitWasTapped(_ sender: Any)
    {
        if(flagDescription.text != "")
        {
            if(incident != nil)
            {
                let referrence : DatabaseReference  = FireDatabaseService.shared.flagReference.childByAutoId()
                let dateString = String(describing: Date())
                let currentUserEmail = Auth.auth().currentUser?.email
                let parameters = ["flaggerEmail"       : currentUserEmail!,
                                  "flagDescription"    : flagDescription.text!,
                                  "postId"             : incident.postId,
                                  "date"               : dateString] as [String : Any]
                referrence.setValue(parameters)
                flagDescription.text = ""
                view.endEditing(true)
                //dismiss(animated: true, completion: nil)
				self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
        else
        {
            AlertController.showAlert(self, title: "Missing flag description informaton", message:"Please enter a comment in the flag report text field.")
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
	
    //MARK: - Set Battery and Time to light
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

    @objc func tapDone(sedner: Any)
    {
        self.view.endEditing(true)
    }
	
	
}
extension UITextView {
    
    func addDoneButton(title: String, target: Any, selector: Selector) {
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0,
                                              y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))//1
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)//2
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)//3
        toolBar.setItems([flexible, barButton], animated: false)//4
        self.inputAccessoryView = toolBar//5
    }
}
