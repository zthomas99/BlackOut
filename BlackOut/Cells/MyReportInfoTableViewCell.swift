//
//  MyReportInfoTableViewCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/21/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class MyReportInfoTableViewCell: UITableViewCell {

	@IBOutlet weak var lblReportTitle: UILabel!
	@IBOutlet weak var txtReportView: UITextView!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
