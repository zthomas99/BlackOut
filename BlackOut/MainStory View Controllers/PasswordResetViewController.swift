//
//  PasswordResetViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/18/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import FirebaseAuth

class PasswordResetViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var txtEmailReset: UITextField!
    @IBOutlet var psswdResetBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        psswdResetBtn.layer.cornerRadius = 15

        txtEmailReset.layer.masksToBounds = false;
        //txtEmailReset.layer.shadowOffset  = CGSize(width: 1,height: 2)
        txtEmailReset.layer.shadowRadius = 5
        //txtEmailReset.layer.shadowOpacity = 0.5
        txtEmailReset.layer.borderWidth = 1.0
        
        txtEmailReset.delegate = self

        self.registerHideKeyboardTappAround()
        self.EnableUITapGesture()
    }
    
    @IBAction func PasswordResetTapped(_ sender: Any)
    {
        let email = txtEmailReset.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if email.isEmpty {
            AlertController.showAlert(self, title: "Password Reset Error", message: "Please enter a valid email to reset your password")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error as NSError? {
                let authCode = AuthErrorCode(rawValue: error.code)
                let message: String

                switch authCode {
                case .invalidEmail:
                    message = "Please enter a valid email address."
                case .userNotFound:
                    message = "No account exists for that email address."
                case .networkError:
                    message = "Network error. Please check your connection and try again."
                case .tooManyRequests:
                    message = "Too many attempts. Please wait and try again."
                case .internalError:
                    message = "Firebase returned an internal error. Check console logs for details."
                default:
                    message = error.localizedDescription
                }

                print("Password reset failed. domain=\(error.domain) code=\(error.code) userInfo=\(error.userInfo)")
                AlertController.showAlert(self, title: "Password Reset Error", message: message)
                return
            }

            AlertController.showAlert(self, title: "Successful", message: "A password reset was sent to the following email: " + email)
        }
    }
    
    @IBAction func CancelButtonTapped(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
