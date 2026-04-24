//
//  AdviceCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/14/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class AdviceCell: UITableViewCell {
	@IBOutlet weak var lblDate: UILabel!
	
	@IBOutlet weak var addCommentBtn: UIButton!
	@IBOutlet weak var btnUsernameOverlay: UIButton!
	
	@IBOutlet weak var lblAdviceComment: UILabel!
	@IBOutlet weak var lblVoteCount: UILabel!
	@IBOutlet weak var downVoteBtn: UIButton!
	@IBOutlet weak var viewRepliesBtn: UIButton!
	@IBOutlet weak var upVoteBtn: UIButton!
	@IBOutlet weak var lblUsername: UILabel!
	
	@IBOutlet weak var navigatonView: UIView!
	
	
	var advice : Advice?
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
