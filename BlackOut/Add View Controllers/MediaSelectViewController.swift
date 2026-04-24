//
//  MediaSelectViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/24/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import DKImagePickerController
import DKCamera
class MediaSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
	
	@IBOutlet weak var btnCamera: UIButton!
	
    
    var pickerController: DKPickViewController?
    
    @IBOutlet weak var mediaContainer: UIView!
	var customCamera : CustomCamera?
	 var didCancel: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
		mediaContainer.layer.borderColor = UIColor.black.cgColor
		mediaContainer.layer.borderWidth = 2.0
		btnCamera.dropShadow(color: UIColor.black)
		customCamera = CustomCamera()
		if UIImagePickerController.isSourceTypeAvailable(.camera)
		{
			customCamera?.sourceType = .camera
		}
		setupDidCancel()
		setupDidFinishCaptureImage()
		setupDidFinishCaptureVideo()
    }
	@IBAction func camerButtonWasTapped(_ sender: Any) {
		self.present(customCamera!, animated: true, completion: nil)
	}
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
		self.didCancel?()
	}
	func saveImageToPhotoGallery(_ image: UIImage)
	{
		UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSaveWithError:contextInfo:)), nil)
	}
	
	func saveVideoToGallery(_ url: URL)
	{
		UISaveVideoAtPathToSavedPhotosAlbum(url.path, self, #selector(video(_:didFinishVideoSaveWithError:contextInfo:)), nil)
	}
	
	@objc func video(_ videoPath : String, didFinishVideoSaveWithError error: Error?, contextInfo :AnyObject)
	{
		if let saveError = error
		{
			AlertController.showAlert(self, title: "Video Save Error", message: "The following error was thrown when saving video to photo gallery \(saveError.localizedDescription)")
		}
	}
	
	@objc func image(_ image:UIImage, didFinishSaveWithError error : Error?, contextInfo: UnsafeRawPointer)
	{
		if let saveError = error
		{
			AlertController.showAlert(self, title: "Save Image Error", message: "The following error was thrown when saving image to photo gallery \(saveError.localizedDescription)")
		}
	}
	func setupDidFinishCaptureImage()
	{
		customCamera?.setDidFinishCapturingImage(block: {image in
			self.saveImageToPhotoGallery(image)
			self.customCamera?.dismiss(animated: true, completion: nil)
		})
	}
	
	func setupDidFinishCaptureVideo()
	{
		customCamera?.setDidFinishCapturingVideo(block: {url in
			self.saveVideoToGallery(url)
			self.customCamera?.dismiss(animated: true, completion: nil)
		})
	}
	
	func setupDidCancel()
	{
		customCamera?.setDidCancel {
			self.customCamera?.dismiss(animated: true, completion: nil)
		}
	}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ToPickerViewController")
        {
			pickerController = (segue.destination as? DKPickViewController)!
			pickerController?.sourceType = .photo
        }
    }
}
