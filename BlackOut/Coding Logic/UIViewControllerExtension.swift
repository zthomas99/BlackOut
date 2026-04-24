//
//  UIViewControllerExtension.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/20/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
	
	
    func registerHideKeyboardTappAround()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard));
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        tap.view!.tag = 99
    }
    
    func DisableUITapGesture()
    {
        let recognizers  = view.gestureRecognizers
        
        for gesture in recognizers!
        {
            if(gesture.view!.tag == 99)
            {
                gesture.isEnabled = false
            }
        }
    }
    
    func EnableUITapGesture()
    {
        let recognizers  = view.gestureRecognizers
        
        for gesture in recognizers!
        {
            if(gesture.view!.tag == 99)
            {
                gesture.isEnabled = true
            }
        }
    }

    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
	
	func transitionInController(_ viewControllerToPresent: UIViewController)
	{
		let transition = CATransition()
		transition.duration = 0.25
		transition.type = kCATransitionPush
		transition.subtype = kCATransitionFromRight
		self.view.window!.layer.add(transition, forKey: kCATransition)
		present(viewControllerToPresent, animated: false)
	}
	
	func transitionOutController()
	{
		let transition = CATransition()
		transition.duration = 0.5
		transition.type = kCATransitionPush
		transition.subtype = kCATransitionFromLeft
		transition.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionEaseOut)
		view.window!.layer.add(transition, forKey: kCATransition)
		//dismiss(animated: false, completion: nil)
	}
}
