//
//  ReportCamera.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/18/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit
import MobileCoreServices
import DKImagePickerController

open class ReportCamera : DKImageBaseExtension, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
	var didCancel: ( () -> Void)?
	var didFinishCapturingImage: ((_ image: UIImage, _ metadata: [AnyHashable : Any]?) -> Void)?
	var didFinishCapturingVideo: ((_ videoURL: URL) ->Void)?
	var camera : UIImagePickerController?
	
	open override func perform(with extraInfo: [AnyHashable : Any]) {
		guard let didFinishCapturingImage = extraInfo["didFinishCapturingImage"] as? ((UIImage, [AnyHashable : Any]?) -> Void),
		let didFinishCapturingVideo = extraInfo["didFinishCapturingVideo"] as? ((URL) ->Void),
			let didCancel = extraInfo["didCancel"] as? (() -> Void) else {return}
		
		self.didFinishCapturingImage = didFinishCapturingImage
		self.didFinishCapturingVideo = didFinishCapturingVideo
		self.didCancel = didCancel
		if UIImagePickerController.isSourceTypeAvailable(.camera)
		{
		camera?.sourceType = .camera
		camera?.delegate = self
		camera?.videoQuality = .typeHigh
		camera?.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
		camera = UIImagePickerController()
		}
		
		self.context.imagePickerController.presentCamera()
	}
	
	open override func finish() {
		//do nothing
		self.context.imagePickerController.dismissCamera()
	}
	
	public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let mediaType = info[UIImagePickerControllerMediaType] as! String
		
		if mediaType == kUTTypeImage as String{
			let metadata = info[UIImagePickerControllerMediaMetadata] as! [AnyHashable : Any]
			let image = info[UIImagePickerControllerOriginalImage] as! UIImage
			self.didFinishCapturingImage?(image, metadata)
		}
		else if mediaType == kUTTypeMovie as String{
			let videoURL = info[UIImagePickerControllerMediaURL] as! URL
			self.didFinishCapturingVideo?(videoURL)
		}
		
	
	}
	
	public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		self.didCancel?()
	}
}
