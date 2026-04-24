//
//  BusinessPhotoViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/24/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class BusinessPhotoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker : UIImagePickerController?
    var businessImage : UIImage?
    var estabSearch : AddSearchViewController?
    
    @IBOutlet weak var defaultBusinessImageView: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		defaultBusinessImageView.layer.masksToBounds = true
		let startPoint = CGPoint(x: 0.5, y: 0.3)
		let endPoint = CGPoint(x: 0.5, y: 1.0)
		self.view.layerGradient(primaryColor: UIColor.black.cgColor, secondaryColor: UIColor.white.cgColor, startPoint: startPoint, endPoint: endPoint)
    }
    
    @IBAction func PhotoButtonTapped(_ sender: UIButton)
    {
		sender.preventRepeatedPresses(inNext: 1)
		if imagePicker == nil
		{
			imagePicker = UIImagePickerController()
			imagePicker?.delegate = self
		}
        imagePicker?.allowsEditing = false
        imagePicker?.mediaTypes = [kUTTypeImage as String]
        self.present(imagePicker!, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            defaultBusinessImageView.contentMode = .scaleToFill
            businessImage = pickedImage
            defaultBusinessImageView.setImage(pickedImage, for: .normal)
			picker.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
		picker.dismiss(animated: true, completion: nil)
    }
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage
    {
        let size = image.size
        
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        //Figure out what our orientation is, and use that to form the recatangle
        var newSize: CGSize
        if(widthRatio > heightRatio)
        {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * widthRatio)
        }
        else
        {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * heightRatio)
        }
        
        //This is the rect that we've calculated out and this is what is acutally used below
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        //Actually do the resizing to the rect using the ImageContext Stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
