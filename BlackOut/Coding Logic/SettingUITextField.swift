//
//  SettingUITextField.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/8/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class SettingUITextField : UITextField
{
	@IBInspectable
	var txtColor: UIColor = .clear
    {
		didSet{
			textColor = txtColor
		}
    }
	
	@IBInspectable
	var lineColor : UIColor = .clear
	{
		didSet{
			underlined()
		}
	}
	
	@IBInspectable override var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
			self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.underlined()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	func underlined(){
        let border = CALayer()
		let width = CGFloat(2.5)
		border.borderColor = lineColor.cgColor
		border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width * 1.5, height: 1.0)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
	
}
