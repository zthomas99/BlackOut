//
//  FireStorage.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/3/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import Firebase
import Photos

class FireStorage{
    static let storage = Storage.storage()
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
						let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
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
							let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1, 60), actualTime: nil)
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
	func downloadThumbImage(file: String, completion: @escaping (Data?,Error?) -> ())
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
	
	func downloadImage(file: String, completion: @escaping (Data?,Error?) -> ())
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
		
	func UploadSelectedPhotos(reference: DatabaseReference, pickerController: DKPickViewController, completion: @escaping (_ error : Error?) -> ())
    {
		let assetCount = pickerController.selectedAssets.count
        var errorCount :Int  = 0;
		var assetIncrementCount : Int = 0;
		for asset in (pickerController.selectedAssets)
        {
            var fileName: String?
            if let phAsset = asset.originalAsset
            {
                let identifier = NSUUID.init().uuidString
                switch phAsset.mediaType
                {
                case .image:
                    fileName = identifier + ".JPG"
                    let options: PHImageRequestOptions = PHImageRequestOptions()
                    options.version = .original
                    
					asset.fetchImageData(options: options) { (data, _: [AnyHashable : Any]?) in
                        let uploadImageRef = FireStorage.init().mediaReference.child(fileName!)
                        DispatchQueue.main.async
                            {
                                let uploadTask = uploadImageRef.putData(data!, metadata: nil)
                                { (metadata, error) in
                                    if(error != nil)
                                    {
                                        //increment the error count and check to see if the number of errors is equal to the number media items selected. If they are equal, then no media was uploaded successfully. Therefore, a NoMedia child needs to be added to the firebase incident entry to trigger the Cloud functions to add a location entry to Firestore.
                                        print(error!)
                                        errorCount += 1
										assetIncrementCount += 1
                                        if(errorCount == assetCount)
                                        {
											FireDatabaseService.shared.InsertNoMediaChild(reference: reference, completion: {
												()
												in
												if assetIncrementCount == assetCount
												{
													pickerController.deselectAll()
													completion(error)
												}
											})
                                        }
                                    }
                                    else
                                    {
										assetIncrementCount += 1
										FireDatabaseService.shared.AddMediaToReference(reference: reference, media:fileName!, completion: {
											()
											in
											
											if assetIncrementCount == assetCount
											{
												pickerController.deselectAll()
												completion(error)
											}
										})
                                        
                                    }
                                }
                                uploadTask.resume()
                        }
                    }
                case .video:
                    fileName = identifier + ".MOV"
                    asset.fetchAVAsset(completeBlock: {video, info in
                        if let urlAsset = video as? AVURLAsset
                        {
                            do
                            {
                                let videoData = try Data(contentsOf: urlAsset.url)
                                DispatchQueue.main.async
                                    {
                                        FireStorage.init().mediaReference.child(fileName!).putData(videoData, metadata: nil, completion: {(metadata, error) in
                                            if(error != nil)
                                            {
                                                //increment the error count and check to see if the number of errors is equal to the number media items selected. If they are equal, then no media was uploaded successfully. Therefore, a NoMedia child needs to be added to the firebase incident entry to trigger the Cloud functions to add a location entry to Firestore.
                                                print(error!)
                                                errorCount += 1
												assetIncrementCount += 1
                                                if(errorCount == assetCount)
                                                {
													FireDatabaseService.shared.InsertNoMediaChild(reference: reference, completion: {
														()
														
														in
														
														if assetIncrementCount == assetCount
														{
															pickerController.deselectAll()
															completion(error)
														}
													})
                                                }
                                            }
                                            else
                                            {
												assetIncrementCount += 1
												FireDatabaseService.shared.AddMediaToReference(reference: reference, media: fileName!, completion: {
													()
													
													in
													if assetIncrementCount == assetCount
													{
														pickerController.deselectAll()
														completion(error)
													}
													
												})
                                            }
                                        })
                                }
                            }
                            catch {print("error in video upload")}
                        }
                    })
                default:
                    print("neither video or image")
                }
            }
        }
        
    }
}
