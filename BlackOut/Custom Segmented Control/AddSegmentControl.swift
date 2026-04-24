			//
//  AddSegmentControl.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/26/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
@IBDesignable
class AddSegmentControl: UISegmentedControl{
    
    var buttons =  [UIButton]()
    var selector : UIView!
    var selectedIndex = 0
    
    @IBInspectable
    var borderWidth: CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = .clear
    {
        didSet
        {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = frame.height/2
    }
    
    @IBInspectable
    var commaSeparatedButtonTitles: String = ""
    {
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var textColor: UIColor = .lightGray
    {
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var selectorColor: UIColor = .darkGray
    {
        didSet{
        updateView()
        }
    }
    
    @IBInspectable
    var selectorTextColor : UIColor = .white
    {
        didSet{
            updateView()
        }
    }
    
    
    func updateView()
    {
        buttons.removeAll()
        subviews.forEach{ $0.removeFromSuperview()}
        
        let buttonTitles = commaSeparatedButtonTitles.components(separatedBy: ",")
        for buttonTitle in buttonTitles
        {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
		let selectorWidth = buttons[selectedIndex].frame.width;
        selector = UIView(frame:  CGRect(x: 0, y: 0, width: selectorWidth, height: frame.height))
        selector.backgroundColor = selectorColor
        selector.layer.cornerRadius = frame.height / 2
        addSubview(selector)
        
        let sv = UIStackView(arrangedSubviews:buttons)
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        
    }
    
    @objc func buttonTapped(button:UIButton)
    {
        for (buttonIndex, btn) in buttons.enumerated(){
            btn.setTitleColor(textColor, for: .normal)
            
            if btn == button
            {
                let selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.3, animations: {self.selector.frame.origin.x = selectorStartPosition})
                btn.setTitleColor(selectorTextColor, for: .normal)
                selectedIndex = buttonIndex
            }
        }
        sendActions(for: .valueChanged)
    }

}
