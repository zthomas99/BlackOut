//
//  StoryViewExtension.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/13/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class StoryTextView: UITextView
{
	@IBInspectable
	var borderColor : UIColor = .clear
	{
		didSet{
			layer.borderColor = borderColor.cgColor
		}
	}
	
	@IBInspectable
	var borderWidith : CGFloat = 0
	{
		didSet{
			layer.borderWidth = borderWidith
		}
	}
	
	@IBInspectable
	var cornerRadius: CGFloat = 0
	{
		didSet{
			layer.cornerRadius = cornerRadius
		}
	}
}
