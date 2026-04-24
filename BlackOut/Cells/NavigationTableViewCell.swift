//
//  NavigationTableViewCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/15/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class NavigationTableViewCell: UITableViewCell {
	@IBOutlet weak var btnComment: UIButton!
	@IBOutlet weak var btnReport: UIButton!
	@IBOutlet weak var lblCommentCount: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
