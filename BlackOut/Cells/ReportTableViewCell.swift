//
//  ReportTableViewCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 10/29/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit

class ReportTableViewCell: UITableViewCell {

    @IBOutlet var reportDescriptionLabel: UILabel!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var datePostedLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

	override func layoutSubviews() {
		super.layoutSubviews()
		contentView.frame = contentView.frame.insetBy(dx: 5, dy: 8)
		contentView.layer.cornerRadius = 5
		contentView.dropContentShadow(scale: true)
	}
	
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	}
