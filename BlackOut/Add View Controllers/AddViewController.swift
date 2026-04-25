//
//  AddTableViewController.swift
//  BlackOut
//
//  Created by Zacch Thomas on 10/7/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()

        view.subviews.forEach { $0.isHidden = true }

        let reportVC = AddReportViewController()
        addChild(reportVC)
        reportVC.view.frame = view.bounds
        reportVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(reportVC.view)
        reportVC.didMove(toParent: self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
}
