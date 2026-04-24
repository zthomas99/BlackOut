//
//  UIViewExtension.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/23/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class LocationCanvas: UIView {
    
    @IBInspectable
    var borderWidth: CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0{
        didSet{
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = .clear{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var primaryColor: UIColor = .clear
    {
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var secondaryColor: UIColor = .clear
    {
        didSet{
            updateView()
        }
    }
    
    func updateView()
    {
        dropShadow()
        let colors: [UIColor] = [primaryColor, secondaryColor]
        let percentages: [Double] = [65,35]
        addColors(colors: colors, withPercentage: percentages)
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowOffset = .zero
        layer.shadowRadius = 3
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func addColors(colors: [UIColor], withPercentage percentages: [Double]) {
        let gradientLayer = CAGradientLayer()
		let glFrame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.frame.width * 1.2, height: self.frame.height - 3)
        gradientLayer.frame = glFrame
        var colorsArray: [CGColor] = []
        var locationsArray: [NSNumber] = []
        var total = 0.0
        locationsArray.append(0.0)
        for (index, color) in colors.enumerated() {
            // append same color twice
            colorsArray.append(color.cgColor)
            colorsArray.append(color.cgColor)
            // Calculating locations w.r.t Percentage of each
            if index+1 < percentages.count{
                total += percentages[index]
                let location: NSNumber = NSNumber(value: total/100)
                locationsArray.append(location)
                locationsArray.append(location)
            }
        }
        locationsArray.append(1.0)
        gradientLayer.colors = colorsArray
        gradientLayer.locations = locationsArray
        gradientLayer.cornerRadius = cornerRadius

        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
