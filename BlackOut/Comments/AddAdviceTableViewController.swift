//
//  AddAdviceTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/10/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class AddAdviceTableViewController: UITableViewController {
	@IBOutlet weak var lblReportTitle: UILabel!
	@IBOutlet weak var txtCommentView: UITextView!
	
	var postId : String?
	var reportTitle : String?
	var instanceOfCommentTableViewController : CommentsTableViewController?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.rowHeight = UITableView.automaticDimension
		txtCommentView.text = ""
		lblReportTitle.text = reportTitle
		txtCommentView.becomeFirstResponder()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

	@IBAction func SendButtonWasTapped(_ sender: Any) {
		let fireDatabaseService = FireDatabaseService()
		let err = fireDatabaseService.SubmitAdvice(postId: postId!, comment: txtCommentView.text)
		if err != nil
		{
			let error : Error = err as! Error
			AlertController.showAlert(self, title: "Failure to submit advice", message: "Failed to submit advice with the following error \(error)")
		}
		else
		{
			instanceOfCommentTableViewController?.Reload()
			self.dismiss(animated: true, completion: nil)
		}
	}
	
	@IBAction func CancelButtonWasTapped(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
}
