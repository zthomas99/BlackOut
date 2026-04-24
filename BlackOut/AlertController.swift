//
//  AlertController.swift
//  BlackOut
//
//  Created by Zacch Thomas on 9/23/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import FirebaseAuth

class AlertController{
    static func showAlert(_ inViewController: UIViewController, title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        inViewController.present(alert, animated: true, completion: nil)
    }
}
