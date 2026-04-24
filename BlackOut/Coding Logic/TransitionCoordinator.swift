//
//  SlideInPresentationManager.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/19/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class TransitionCoordinator: NSObject, UINavigationControllerDelegate{
	
	func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return nil
	}
}
