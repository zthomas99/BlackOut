//
//  CommentHeaderView.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/8/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class AdviceHeaderView: UIView {

	@IBOutlet weak var lblDate: UILabel!
	@IBOutlet weak var lblUsername : UILabel!
	@IBOutlet weak var txtViewComment : UITextView!
	@IBOutlet weak var lblVoteCount : UILabel!
	
	// Btn Outlets
	@IBOutlet weak var addReply : UIButton!
	@IBOutlet weak var viewRepliesBtn : UIButton!
	@IBOutlet weak var upVoteBtn : UIButton!
	@IBOutlet weak var downVoteBtn : UIButton!
	var advice : Advice?
	
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */


}
