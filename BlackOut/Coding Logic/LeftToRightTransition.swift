//
//  LeftToRightTransition.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/20/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import UIKit

class LeftToRightTransition: NSObject, UIViewControllerAnimatedTransitioning{
	
	let duration: TimeInterval = 0.25
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return duration
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let container = transitionContext.containerView
		let fromView = transitionContext.view(forKey: .from)!
		
		container.addSubview(fromView)
		fromView.frame.origin = .zero
		
		UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
			fromView.frame.origin = CGPoint(x: fromView.frame.width, y: 0)
		}, completion: { _ in
			fromView.removeFromSuperview()
			transitionContext.completeTransition(true)
		})
	}
}
