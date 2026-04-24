//
//  SlidePresentationManager.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/19/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import UIKit

extension SlideInPresentationManager: UIViewControllerTransitioningDelegate{
	var direction : PresentatonDirection = .left
	lazy var slideInTransistionDelegate = SlideInPresentationManager()
	
	
}
enum PresentatonDirection
{
	case left
	case top
	case right
	case bottom
}
