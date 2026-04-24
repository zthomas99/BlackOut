//
//  BlockedCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/16/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class BlockedCell: UITableViewCell {

	@IBOutlet weak var lblBlockedUser: UILabel!
	@IBOutlet weak var btnUnblock: UIButton!
	override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
