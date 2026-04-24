//
//  MediaCollectionViewCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/5/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import AVKit

class MediaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var mediaThumbnail: UIImageView!
    var originalImage: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 207.0, height: 207.0))
    lazy var playButton: UIButton =
    {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play.png")
        button.setImage(image, for: .normal)
        button.tintColor = UIColor.white
        return button
    }()
	
//	override func layoutSubviews() {
//		super.layoutSubviews()
//		if mediaThumbnail.image != nil
//		{
//		let imageViewFrame = CGRect(x: 0, y: 0, width: 207.0, height: 207.0)
//		let aspectFrame = AVMakeRect(aspectRatio: mediaThumbnail.image!.size, insideRect: imageViewFrame)
//		self.frame.size = aspectFrame.size
//		}
//	}
}
