//
//  SlideInSegue.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/17/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import UIKit

class SlideInSegue: UIStoryboardSegue {
private var selfRetainer : SlideInSegue? = nil
	
	override func perform()
	{
		destination.transitioningDelegate = self
		selfRetainer = self
		destination.modalPresentationStyle = .overCurrentContext
		source.present(destination, animated: true, completion: nil)
	}
}
extension SlideInSegue : UIViewControllerTransitioningDelegate
{
	public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
	{
		return RightToLeftTransition()
	}
	
	public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?
	{
		selfRetainer = nil
		return LeftToRightTransition()
	}
}
