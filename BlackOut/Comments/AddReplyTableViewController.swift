//
//  AddReplyTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/10/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class AddReplyTableViewController: UITableViewController {

	@IBOutlet weak var lblQuoteUser: UILabel!
	@IBOutlet weak var lblQuoteDate: UILabel!
	@IBOutlet weak var adviceTextView: UITextView!
	@IBOutlet weak var replyTextView: UITextView!
	@IBOutlet weak var lblReplyTitle: UILabel!
	var isReplyToAdvice : Bool!
	var advice : Advice?
	var reply : Reply?
	var tag:Int?
	var postId : String!
	var instanceOfCommentTableViewController : CommentsTableViewController?
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		replyTextView.text = ""
		tableView.tableFooterView = UIView()
		
		if isReplyToAdvice
		{
			adviceTextView.text = advice?.comment
		
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .medium
			dateFormatter.timeZone = .none
			dateFormatter.locale = Locale(identifier: "en_US")
		
			lblReplyTitle.text = "Add Comment to Advice"
			lblQuoteDate.text = dateFormatter.string(from:advice!.date)
			lblQuoteUser.text = advice?.user
		}
		else
		{
				adviceTextView.text = reply?.comment
			
				let dateFormatter = DateFormatter()
				dateFormatter.dateStyle = .medium
				dateFormatter.timeZone = .none
				dateFormatter.locale = Locale(identifier: "en_US")
				lblReplyTitle.text = "Reply to Comment"
				lblQuoteDate.text = dateFormatter.string(from:reply!.date)
				lblQuoteUser.text = reply?.user
		}
		replyTextView.becomeFirstResponder()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

	@IBAction func ReplyButtonTapped(_ sender: Any) {
		
		if isReplyToAdvice
		{
			CommentService.shared.submitReply(postId: postId, comment: replyTextView.text, advice: advice!, completion: { [weak self] error in
				Task { @MainActor in
					guard let self = self else { return }
					if let error = error
					{
						AlertController.showAlert(self, title: "Add Commennt Error, Try again. ", message: "Unable to add comment to the advice, due to the following error \(error) ")
					}
					else
					{
						self.instanceOfCommentTableViewController?.ReloadByIndex(index: self.tag!)
						self.dismiss(animated: true, completion: nil)
					}
				}
			})
		}
		else {
			CommentService.shared.submitReplyToReply(postId: postId, comment: replyTextView.text, advice: advice!, reply: reply!, completion: { [weak self] error in
				Task { @MainActor in
					guard let self = self else { return }
					if let error = error
					{
						AlertController.showAlert(self, title: "Add Commennt Error, Try again. ", message: "Unable to add comment to the reply, due to the following error \(error) ")
					}
					else
					{
						self.instanceOfCommentTableViewController?.ReloadByIndex(index: self.tag!)
						self.dismiss(animated: true, completion: nil)
					}
				}
			})
		}
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.row == 1
		{
			return 300
		}
		return UITableView.automaticDimension
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 1.0
	}
	@IBAction func CancelButtonTapped(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	
	//MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

}
