//
//  LocationTableViewCell.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/24/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
import AVFoundation
class MediaLocationCell: UITableViewCell  {

	
	@IBOutlet weak var imageCollectionView: UICollectionView!
	var imageList = [String]()

	@IBOutlet weak var lblLocationTitle: UILabel!
	@IBOutlet weak var lblAddress: UILabel!
	@IBOutlet weak var lblReportCount: UILabel!
	@IBOutlet weak var topMediaBtn: UIButton!
	@IBOutlet weak var bottomMediaBtn: UIButton!
	

    override func awakeFromNib() {
        super.awakeFromNib()
		imageCollectionView.delegate = self
		imageCollectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
	
}
extension MediaLocationCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return imageList.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let row = indexPath.row
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocalMediaCell", for: indexPath) as? LocalMediaCollectionViewCell
		cell?.layer.borderColor = UIColor(displayP3Red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6).cgColor
		cell?.layer.cornerRadius = 15.0
		cell?.layer.masksToBounds = true
		cell?.layer.borderWidth = 0.5
		cell?.tag = imageCollectionView.tag
		let ext = FireStorage.shared.RetrieveExtension(fileName: imageList[row])
		if ext == "JPG"
		{
			cell?.LocationImage.loadImage(file: imageList[row], view: "search")
		}
		else
		{
			cell?.LocationImage.loadThumbnail(file: imageList[row], view: "search")
		}
		cell?.contentView.layer.cornerRadius = 15.0
		cell?.contentView.layer.masksToBounds = true
		return cell!
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 5
	}
//	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocalMediaCell", for: 	indexPath) as? LocalMediaCollectionViewCell
//		let imageSize = cell?.LocationImage.imageSize()
//		let imageViewFrame = CGRect(x: 0, y: 0, width: 217.0, height: 217.0)
//		let aspectFrame = AVMakeRect(aspectRatio: imageSize!, insideRect: imageViewFrame)
//		return CGSize(width:aspectFrame.width, height: aspectFrame.height)
//	}
//
//	func downloadMedia()
//	{
//		let fireStorageService = FireStorage()
//		fireStorageService.downloadMediaList(mediaList: imageList, completion: {
//			(images)
//			in
//			self.images = images
//			self.imageCollectionView.reloadData()
//		})
//	}
	
}
