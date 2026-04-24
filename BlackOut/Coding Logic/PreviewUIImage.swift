//
//  PreviewUIImage.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/31/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//
import Foundation
import UIKit

@IBDesignable
class PreviewUIImage: UIImageView {

   override init(image: UIImage?) {
       super.init(image: image)

   }

   override init(frame: CGRect) {
       super.init(frame: frame)
   }

   required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
   }

    @IBInspectable
    var borderColor: UIColor = .clear{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowOffset = CGSize(width: 2.0,height: 2.0)
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
   override func layoutSubviews() {
       super.layoutSubviews()
       self.layer.cornerRadius = 15
   }
}
