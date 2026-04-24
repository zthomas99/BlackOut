//
//  LocalMediaCollectionViewCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/22/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit
import AVKit
class LocalMediaCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var LocationImage: UIImageView!

	//commented out for possible later use
	//The following invalidates a layout and changes the size of a
	//collection view cell according to the aspect ratio of the image.
//	override func layoutSubviews() {
//		super.layoutSubviews()
//		if LocationImage.image != nil
//		{
//		let imageViewFrame = CGRect(x: 0, y: 0, width: 217.0, height: 217.0)
//		let aspectFrame = AVMakeRect(aspectRatio: LocationImage.image!.size, insideRect: imageViewFrame)
//		self.frame.size = aspectFrame.size
//		}
//	}
}
