//
//  PostCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/14/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

	@IBOutlet weak var lblReportTitle: UILabel!
	@IBOutlet weak var lbllUsername: UILabel!
	@IBOutlet weak var reportTextView: UITextView!
	@IBOutlet weak var lblDate: UILabel!
	@IBOutlet weak var addAdviceBtn: UIButton!

	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
		reportTextView.layer.cornerRadius = 20.0
        // Configure the view for the selected state
    }

}
