//
//  UIViewExtension.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/5/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import UIKit

extension UIView
{
    func addBlurToView()
    {
        var blurEffect: UIBlurEffect!
        if #available(iOS 10.0, *)
        {
            blurEffect = UIBlurEffect(style: .dark)
        }
        else
        {
            blurEffect = UIBlurEffect(style: .light)
        }
        
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = self.bounds
        blurredEffectView.alpha = 0.6
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.insertSubview(blurredEffectView, at: 0)
    }
    
	func layerGradient(primaryColor: CGColor, secondaryColor: CGColor, startPoint: CGPoint, endPoint: CGPoint) {
        let layer : CAGradientLayer = CAGradientLayer()
        layer.frame.size = self.frame.size
		layer.frame.origin = .zero
		layer.startPoint = startPoint
		layer.endPoint = endPoint
        layer.colors = [primaryColor,secondaryColor]
		self.layer.insertSublayer(layer, at: 0)
    }
	
    func removeBlurFromView()
    {
        for subview in self.subviews
        {
            if subview is UIVisualEffectView
            {
                subview.removeFromSuperview()
            }
        }
    }
	
	func dropShadow(scale: Bool = true, color: UIColor) {
        layer.masksToBounds = false
		layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowOffset = CGSize(width: 2.0,height: 2.0)
        layer.shadowRadius = 4
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
		
	func dropContentShadow(scale: Bool = true) {
		layer.masksToBounds = false
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.9
		layer.shadowOffset = .zero
		layer.shadowRadius = 2
		layer.shouldRasterize = true
		layer.rasterizationScale = scale ? UIScreen.main.scale : 1
	}
}


extension NSObject {
	func copyObject<T:NSObject>() throws -> T? {
		let data = try NSKeyedArchiver.archivedData(withRootObject:self, requiringSecureCoding:false)
		return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T
	}
}
extension UITextView {

    func addDoneButton(title: String, target: Any, selector: Selector) {
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0,
                                              width: UIScreen.main.bounds.size.width,
                                              height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: title, style: .plain, target: target, action: selector)
        toolBar.setItems([flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
}

extension UITextField
{
	
	@IBInspectable var placeHolderColor: UIColor? {
        get {
            guard let attributed = self.attributedPlaceholder,
                  attributed.length > 0,
                  let color = attributed.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor else {
                return nil
            }
            return color
        }
        set {
			self.attributedPlaceholder = NSAttributedString(string: self.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor: newValue ?? UIColor.lightGray])
        }
    }
	
	@IBInspectable
	var borderWidth: CGFloat {
		get
		{
			return layer.borderWidth
		}
		set{
			layer.borderWidth = newValue
		}
	}
	
	@IBInspectable
	var borderColor : UIColor
	{
		get
		{
			return UIColor(cgColor: layer.borderColor!)
		}
		set
		{
			layer.borderColor =  newValue.cgColor
		}
	}
	
}
