//
//  ReplyCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/8/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class ReplyCell: UITableViewCell {

	
	@IBOutlet weak var textViewComment: UITextView!
	@IBOutlet  var lblDate: UILabel!
	@IBOutlet weak var lblUsername: UILabel!
	@IBOutlet weak var replyBtn: UIButton!
	@IBOutlet weak var btnUsernameOverlay: UIButton!
	

	var selectReply: Reply?
	var row : Int?
	var instanceOfCommentTableVewControler : CommentsTableViewController?
	
	//MARK: - Initialize Cell
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}
	
	//MARK: - Setup and Style Cell
	func SetUpCell(cellReply : Reply, commentTableViewController: CommentsTableViewController, forIndex indexPath: IndexPath)
	{
		self.selectReply = cellReply
		instanceOfCommentTableVewControler = commentTableViewController
		row = indexPath.row
		self.tag = indexPath.section
		replyBtn.addTarget(self, action: #selector(PresentAddReplyController), for: .touchUpInside)
	}
	
	func StyleCell()
	{
		guard let selectReply = selectReply else { return }
		lblUsername.text = selectReply.user
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeZone = .none
		dateFormatter.locale = Locale(identifier: "en_US")
		
		let calendar = Calendar.current
		if calendar.isDate(selectReply.date, inSameDayAs: Date())
		{
			lblDate.text = Date().timeAgo(compare: selectReply.date)
		}
		else
		{
			lblDate.text = dateFormatter.string(from: selectReply.date)
		}

		textViewComment.text = selectReply.comment
	}
	
	//MARK: - Protocol Delegate
	@objc func PresentAddReplyController()
	{
		guard let identifier = self.accessibilityIdentifier, let section = Int(identifier) else { return }
		instanceOfCommentTableVewControler?.ShowAddReply(sender: IndexPath(row: self.tag, section: section))
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
	
}
