//
//  FireStorage.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/3/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
@preconcurrency import Firebase
import Photos

class FireStorage: @unchecked Sendable {
    nonisolated(unsafe) static let storage = Storage.storage()
	static let shared = FireStorage()
    init(){}
    let mediaReference = storage.reference().child("media")
	let thumbReference = storage.reference().child("media").child("thumbnails")
	
	
	func downloadMediaList(mediaList: [String], completion: @escaping ([UIImage]) -> ())
	{
		var fileCounter = 0
		let fileCount = mediaList.count
		var images = [UIImage]()
		
		for file in mediaList
		{
			//let childPath:String = "media/" + imageName
			let fileName = file
			let fileExtension = RetrieveExtension(fileName: file)
			if(fileExtension == "JPG")
			{
				mediaReference.child(fileName).getData(maxSize: 1 * 100000 * 100000)
				{ (data, error) in
					if(error != nil)
					{
						fileCounter += 1
						print("The following error was thrown when attempting to download the following file : \(fileName) error: \(String(describing: error))")
						if fileCount == fileCounter
						{
							completion(images)
						}
						
						
					}
					else
					{
						
						let image = UIImage(data: data!)
						images.append(image!)
						fileCounter += 1
						if fileCount == fileCounter
						{
							completion(images)
						}
					}
				}
			}
			else
			{
				mediaReference.child(fileName).downloadURL { (URL, Error) in
					let asset = AVAsset(url: URL!)
					let imageGenerator = AVAssetImageGenerator(asset: asset)
					do
					{
						let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
						let cgImage = UIImage(cgImage: thumbnailCGImage)
						images.append(cgImage)
						fileCounter += 1
						if fileCount == fileCounter
						{
							completion(images)
						}
					}
					catch let err
					{
						fileCounter += 1
						print(err)
						if fileCount == fileCounter
						{
							completion(images)
						}
					}
				}
			}
		}
	}
	
	func downloadMediaCollection(fileArry:[String : [String]], completion: @escaping ([String : [UIImage]]) ->())
    {
		
		var imageMap = [String : [UIImage]]()
		let locationCount = fileArry.count
		var locationCounter = 0
        for location in fileArry
        {
			let fileCount = location.value.count
			var fileCounter = 0
			var images = [UIImage]()
			for file in location.value
			{
                //let childPath:String = "media/" + imageName
                let fileName = file
				let fileExtension = RetrieveExtension(fileName: file)
				if(fileExtension == "JPG")
				{
                mediaReference.child(fileName).getData(maxSize: 1 * 100000 * 100000)
                { (data, error) in
                    if(error != nil)
                    {
						fileCounter += 1
                        print("The following error was thrown when attempting to download the following file : \(fileName) error: \(String(describing: error))")
						if fileCount == fileCounter
						{
							locationCounter += 1
						}
						
						if locationCount == locationCounter
						{
							completion(imageMap)
						}
                    }
					else
					{
						
						let image = UIImage(data: data!)
						images.append(image!)
						fileCounter += 1
						if fileCount == fileCounter
						{
							locationCounter += 1
							imageMap[location.key] = images
						}
						if locationCount == locationCounter
						{
							completion(imageMap)
						}
					}
					}
				}
				else
				{
					mediaReference.child(fileName).downloadURL { (URL, Error) in
						let asset = AVAsset(url: URL!)
						let imageGenerator = AVAssetImageGenerator(asset: asset)
						do
						{
							let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
							let cgImage = UIImage(cgImage: thumbnailCGImage)
							images.append(cgImage)
							fileCounter += 1
							if fileCount == fileCounter
							{
								locationCounter += 1
								imageMap[location.key] = images
							}
							if locationCounter == locationCount
							{
								completion(imageMap)
							}
							
						}
						catch let err
						{
							fileCounter += 1
							print(err)
							if fileCount == fileCounter
							{
								locationCounter += 1
								imageMap[location.key] = images
							}
							if locationCounter == locationCount
							{
								completion(imageMap)
							}
						}
					}
				}
			}
        }
    }
	func downloadThumbImage(file: String, completion: @Sendable @escaping (Data?,Error?) -> ())
	{
		
		let newFileName = RetrieveMovieThumbNailName(fileName: file)
		
		thumbReference.child(newFileName).getData(maxSize: 1 * 100000 * 100000)
		{ (data, error) in
			if(error != nil)
			{
				
				print("The following error was thrown when attempting to download the following file : \(newFileName) error: \(String(describing: error))")
				
				DispatchQueue.main.async {
					completion(data, error)
				}
			}
			else
			{
				
				guard let data = data , error == nil else
				{
					return
				}
				DispatchQueue.main.async {
					completion(data,error)
				}
			}
		}
	}
	
	func downloadImage(file: String, completion: @Sendable @escaping (Data?,Error?) -> ())
	{
		mediaReference.child(file).getData(maxSize: 1 * 100000 * 100000)
		{ (data, error) in
			if(error != nil)
			{
				
				print("The following error was thrown when attempting to download the following file : \(file) error: \(String(describing: error))")
				
				DispatchQueue.main.async {
					completion(data, error)
				}
			}
			else
			{
				
				guard let data = data , error == nil else
				{
					return
				}
				DispatchQueue.main.async {
					completion(data,error)
				}
			}
		}
	}
	
	func RetrieveExtension(fileName:String) ->String
	{
		let ext = fileName.split(separator: ".").last
		let extensionName:String = String(ext!)
		return extensionName
	}
	
	func RetrieveMovieThumbNailName(fileName: String) -> String
	{
		let rootName = fileName.split(separator: ".").first
		let thumbName = "thumb_\(String(describing: rootName ?? "")).JPG"
		return thumbName
	}
		
	private final class UploadProgress: @unchecked Sendable {
		var errorCount = 0
		var completedCount = 0
	}

	@MainActor
	func UploadSelectedPhotos(reference: DatabaseReference, pickerController: DKPickViewController, completion: @Sendable @escaping (_ error: Error?) -> ()) {
		let assets = pickerController.selectedAssets
		let assetCount = assets.count
		let progress = UploadProgress()

		for asset in assets {
			guard let phAsset = asset.originalAsset else { continue }
			let identifier = NSUUID().uuidString
			switch phAsset.mediaType {
			case .image:
				let fileName = identifier + ".JPG"
				let options = PHImageRequestOptions()
				options.version = .original

				asset.fetchImageData(options: options) { (data, _: [AnyHashable: Any]?) in
					guard let data = data else { return }
					let uploadImageRef = FireStorage.shared.mediaReference.child(fileName)
					let uploadTask = uploadImageRef.putData(data, metadata: nil) { metadata, error in
						if error != nil {
							print(error!)
							progress.errorCount += 1
							progress.completedCount += 1
							if progress.errorCount == assetCount {
								FireDatabaseService.shared.InsertNoMediaChild(reference: reference) {
									if progress.completedCount == assetCount {
										Task { @MainActor in pickerController.deselectAll() }
										completion(error)
									}
								}
							}
						} else {
							progress.completedCount += 1
							FireDatabaseService.shared.AddMediaToReference(reference: reference, media: fileName) {
								if progress.completedCount == assetCount {
									Task { @MainActor in pickerController.deselectAll() }
									completion(error)
								}
							}
						}
					}
					uploadTask.resume()
				}
			case .video:
				let fileName = identifier + ".MOV"
				asset.fetchAVAsset(completeBlock: { video, info in
					guard let urlAsset = video as? AVURLAsset,
						  let videoData = try? Data(contentsOf: urlAsset.url) else { return }
					FireStorage.shared.mediaReference.child(fileName).putData(videoData, metadata: nil) { metadata, error in
						if error != nil {
							print(error!)
							progress.errorCount += 1
							progress.completedCount += 1
							if progress.errorCount == assetCount {
								FireDatabaseService.shared.InsertNoMediaChild(reference: reference) {
									if progress.completedCount == assetCount {
										Task { @MainActor in pickerController.deselectAll() }
										completion(error)
									}
								}
							}
						} else {
							progress.completedCount += 1
							FireDatabaseService.shared.AddMediaToReference(reference: reference, media: fileName) {
								if progress.completedCount == assetCount {
									Task { @MainActor in pickerController.deselectAll() }
									completion(error)
								}
							}
						}
					}
				})
			default:
				break
			}
		}
	}
}
