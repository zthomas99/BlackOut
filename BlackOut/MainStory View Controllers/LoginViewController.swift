//
//  ViewController.swift
//  BlackOut
//
//  Created by Zacch Thomas on 9/11/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtEmailLogin: UITextField!
    @IBOutlet weak var txtPasswordLogin: UITextField!
    @IBOutlet var loginBackgroundImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerHideKeyboardTappAround()
        self.EnableUITapGesture()
        txtEmailLogin.delegate = self
        txtPasswordLogin.delegate = self
    }
    
    @IBAction func OnSignUpTap(_ sender: Any)
    {
        self.performSegue(withIdentifier: "LoginToTerms", sender: nil)
    }
    
    @IBAction func OnLoginTap(_ sender: UIButton) {
        
        guard let email = txtEmailLogin.text,
        email != "",
        let password = txtPasswordLogin.text,
        password != ""
        else
        {
            AlertController.showAlert(self, title:"Missing Fields", message: "Please fill out all fields")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            guard error == nil else
            {
                AlertController.showAlert(self, title: "Error", message: error!.localizedDescription)
                return
            }
			if user?.user.isEmailVerified == false
			{
				self.showLoginAlert(title: "Email Verification failure", message: "Email for this user has yet been verified. Would you like to resend the email verficiation?")
				return
			}
			UserService.shared.retrieveCurrentUser(completion: { [weak self] error in
				Task { @MainActor in
					guard let self = self else { return }
					if error != nil
					{
						AlertController.showAlert(self, title: "User Retrieval Error", message: "BlackOut is having difficulty retrieving your user info, please try again.")
						self.signOut()
						self.txtEmailLogin.text = ""
						self.txtPasswordLogin.text = ""
					}
					else
					{
						self.txtEmailLogin.text = ""
						self.txtPasswordLogin.text = ""

						self.performSegue(withIdentifier: "LoginToNavigation", sender: nil)
					}
				}
			})
			
        })
        }
    
	
	func showLoginAlert(title: String, message: String)
	{
		let loginAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let yesAction = UIAlertAction(title: "Yes", style: .default, handler:
		
		{ action in
			self.resendEmailVerfication()
		})
		let noAction = UIAlertAction(title: "No", style: .default, handler: {action in
			self.signOut()
		})
		loginAlert.addAction(yesAction)
		loginAlert.addAction(noAction)
		self.present(loginAlert, animated: true, completion: nil)
	}
	
	func resendEmailVerfication()
	{
		Auth.auth().currentUser?.sendEmailVerification(completion: {(error)
			
			in
			
			if(error != nil)
			{
				
				AlertController.showAlert(self, title: "Resend Email Verifcation Error", message: "There was an error in resending the email verification. Please re-try at a later time.")
			}
			else
			{
				AlertController.showAlert(self, title: "Successful", message: "Email verificiation was resent. Please check your inbox, spam, and junk folder for email.")
				self.signOut()
			}
		})
	}
	
	@IBAction func unwindSignOut(_ seg: UIStoryboardSegue)
	{
		signOut()
	}
	
	func signOut()
	{
		do
        {
            try Auth.auth().signOut()
        }
		catch
        {
			
            return
        }
	}
	
    @IBAction func ForgotPasswordTapped(_ sender: Any)
    {
        self.performSegue(withIdentifier: "LoginToPasswordReset", sender: self)
    }
    
    //MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    //MARK: - UITextFieldDelegate Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return true
    }
    
}
