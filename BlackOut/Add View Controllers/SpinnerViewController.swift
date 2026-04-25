//
//  SpinnerViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/21/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class SpinnerViewController: UIViewController {

	@IBOutlet weak var blurView: UIVisualEffectView!
	var spinner = UIActivityIndicatorView(style: .large)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addBlurToView();
		spinner.startAnimating()
		self.view.addSubview(spinner)
		spinner.center = self.view.center
	}
	
}
