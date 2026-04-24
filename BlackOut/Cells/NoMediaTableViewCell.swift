//
//  NoMediaTableViewCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/22/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class NoMediaTableViewCell: UITableViewCell {

	@IBOutlet weak var btnSelect: UIButton!
	@IBOutlet weak var lblLocationTitle: UILabel!
	@IBOutlet weak var lblAddress: UILabel!
	@IBOutlet weak var lblNumberOfReports: UILabel!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
