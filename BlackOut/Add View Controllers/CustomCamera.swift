//
//  CustomCamera.swift
//  TestDKImagePickerControllerObjc
//
//  Created by ZhangAo on 18/05/2017.
//  Copyright © 2017 booksir. All rights reserved.
//

import DKImagePickerController
import MobileCoreServices

open class CustomCamera: UIImagePickerController,  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var didCancel: (() -> Void)?
    var didFinishCapturingImage: ((_ image: UIImage) -> Void)?
    var didFinishCapturingVideo: ((_ videoURL: URL) -> Void)?
    
    public func setDidCancel(block: @escaping () -> Void) {
        self.didCancel = block
    }
    
    public func setDidFinishCapturingImage(block: @escaping (UIImage) -> Void) {
        self.didFinishCapturingImage = block
    }
    
    public func setDidFinishCapturingVideo(block: @escaping (URL) -> Void) {
        self.didFinishCapturingVideo = block
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
		if UIImagePickerController.isSourceTypeAvailable(.camera)
		{
        self.delegate = self
        self.sourceType = .camera
        self.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
		}
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let mediaType = info[.mediaType] as? String else { return }

        if mediaType == kUTTypeImage as String {
            guard let image = info[.originalImage] as? UIImage else { return }
            self.didFinishCapturingImage?(image)
        } else if mediaType == kUTTypeMovie as String {
            guard let videoURL = info[.mediaURL] as? URL else { return }
            self.didFinishCapturingVideo?(videoURL)
        }
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.didCancel?()
    }
    
}
