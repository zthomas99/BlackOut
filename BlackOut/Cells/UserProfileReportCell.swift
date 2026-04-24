//
//  ProfileReportCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/13/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class UserProfileReportCell: UITableViewCell {

	@IBOutlet weak var lblReportTitle: UILabel!
	@IBOutlet weak var lblReportDescription: UILabel!
	@IBOutlet weak var canvasView: UIView!
	
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
