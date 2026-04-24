//
//  LocationDataSource.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/14/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import UIKit

class LocationDataSource
{
	var  imageDictionary : [Int : [UIImage]] = [Int : [UIImage]]()
	
	
	func clearImages()
	{
		imageDictionary.removeAll()
	}
}
