//
//  UIImageViewExtension.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/28/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import UIKit

nonisolated(unsafe) let imageCache = NSCache<AnyObject, AnyObject>()
nonisolated(unsafe) let fullImageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView{
	
	func loadThumbnail(file: String, view:String)
	{
		let cacheName = "thumb_\(file)_\(view)"
		if let imageFromCache = imageCache.object(forKey: cacheName as AnyObject)
		{
			image = imageFromCache as? UIImage
			return
		}
		
		let fireStorageService = FireStorage()
		fireStorageService.downloadThumbImage(file: file, completion: {
			(data, error)
			in
			if error != nil
			{
				self.image = UIImage(named: "image_thumb.jpg")
			}
			else
			{
				if data != nil
				{
					guard let imageToCache = UIImage(data: data!) else
					{
						return
					}
					imageCache.setObject(imageToCache, forKey: cacheName as AnyObject)
					self.image = UIImage(data: data!)
				}
				else
				{
					self.image = UIImage(named: "image_thumb.jpg")
				}
				
			}
		})
	}
	
	func loadImage(file: String, view:String)
	{
		let cacheName = "full_\(file)_\(view))"
		if let imageFromCache = fullImageCache.object(forKey: cacheName as AnyObject)
		{
			image = imageFromCache as? UIImage
			return
		}
		
		let fireStorageService = FireStorage()
		fireStorageService.downloadImage(file: file, completion: {
			(data, error)
			in
			if error != nil
			{
				self.image = UIImage(named: "image_thumb.jpg")
			}
			else
			{
				if data != nil
				{
					guard let imageToCache = UIImage(data: data!) else
					{
						return
					}
					fullImageCache.setObject(imageToCache, forKey: cacheName as AnyObject)
					self.image = UIImage(data: data!)
				}
				else
				{
					self.image = UIImage(named: "image_thumb.jpg")
				}
				
			}
		})
	}
}
