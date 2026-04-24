//
//  SubReplyCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/29/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class SubReplyCell: UITableViewCell {
	
	@IBOutlet weak var lblQuotedUser: UILabel!

	
	@IBOutlet weak var txtViewComment: UITextView!
	
	@IBOutlet weak var lblUser: UILabel!
	@IBOutlet weak var lblDate: UILabel!

	@IBOutlet weak var btnUsernameOverlay: UIButton!
	@IBOutlet weak var btnShowSourceComment: UIButton!
	
	var instanceOfCommentTableView : CommentsTableViewController?
	var reply : Reply?
	var row : Int?
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	func initializeSubCell(subReply: Reply, commentTableViewController: CommentsTableViewController, forIndex indexPath: IndexPath)
	{
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeZone = .none
		dateFormatter.locale = Locale(identifier: "en_US")
		row = indexPath.row
		self.tag = indexPath.section
	
		reply = subReply
		instanceOfCommentTableView = commentTableViewController
		
		let calendar = Calendar.current
		if calendar.isDate(subReply.date, inSameDayAs: Date())
		{
			lblDate.text = Date().timeAgo(compare: subReply.date)
		}
		else
		{
			lblDate.text = dateFormatter.string(from:subReply.date)
		}
		
		lblQuotedUser.text = "@" + subReply.quoteUser
		lblUser.text = subReply.user
		txtViewComment.text = subReply.comment
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		if selected
		{
			self.contentView.backgroundColor = UIColor(displayP3Red: 254.0/255.0, green: 208/255.0, blue: 28.0/255.0, alpha: 0.7)
		}
		else
		{
			self.contentView.backgroundColor = UIColor.black
		}
        // Configure the view for the selected state
	}
	
	@IBAction func ReplyButtonTapped(_ sender: Any) {
		let section = Int(self.accessibilityIdentifier!)!
		instanceOfCommentTableView?.ShowAddReply(sender: IndexPath(row: self.tag, section: section))
	}
	
}

