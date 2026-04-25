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
        flagDescription.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
    }

    @IBAction func CancelWasTapped(_ sender: Any) {
        dismissFlagFlow()
    }

    @IBAction func SubmitWasTapped(_ sender: Any)
    {
        guard let description = flagDescription.text, !description.isEmpty else {
            AlertController.showAlert(self, title: "Missing flag description informaton", message:"Please enter a comment in the flag report text field.")
            return
        }
        guard let incident = incident,
              let currentUserEmail = Auth.auth().currentUser?.email else { return }

        let reference: DatabaseReference = FireDatabaseService.shared.flagReference.childByAutoId()
        let dateString = String(describing: Date())
        let parameters = ["flaggerEmail"       : currentUserEmail,
                          "flagDescription"    : description,
                          "postId"             : incident.postId,
                          "date"               : dateString] as [String : Any]
        reference.setValue(parameters)
        flagDescription.text = ""
        view.endEditing(true)
        dismissFlagFlow()
    }

    private func dismissFlagFlow() {
        // Dismisses FlagTableViewController + FlagViewController together
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

    @objc func tapDone(sender: Any)
    {
        self.view.endEditing(true)
    }
}
