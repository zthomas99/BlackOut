//
//  SignUpViewController.swift
//  BlackOut
//
//  Created by Zacch Thomas on 9/16/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtEmailSignUp: UITextField!
    
    @IBOutlet weak var txtPasswordSignUp: UITextField!
    
    @IBOutlet weak var txtConfirmPasswordSignUP: UITextField!
    @IBOutlet weak var btnSignUP: UIButton!
    
    var keyboardFrame: CGRect!
    var isViewUp:Bool = false

    override func viewDidLoad()
    {
        super.viewDidLoad()
        //Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(KeyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        txtEmailSignUp.layer.borderWidth = 1.0
        txtEmailSignUp.layer.borderColor = UIColor.black.cgColor
        
        txtPasswordSignUp.layer.borderWidth = 1.0
        txtPasswordSignUp.layer.borderColor = UIColor.black.cgColor
        
        txtConfirmPasswordSignUP.layer.borderWidth = 1.0
        txtConfirmPasswordSignUP.layer.borderColor = UIColor.black.cgColor
        
        btnSignUP.layer.masksToBounds = false;
        btnSignUP.layer.shadowOffset  = CGSize(width: 1,height: 2)
        btnSignUP.layer.shadowRadius = 5
        btnSignUP.layer.shadowOpacity = 0.5
        btnSignUP.layer.borderWidth = 1.0
        btnSignUP.layer.borderColor = UIColor.white.cgColor
        btnSignUP.layer.cornerRadius = 25
        
        txtEmailSignUp.delegate = self
        txtPasswordSignUp.delegate = self
        txtConfirmPasswordSignUP.delegate = self
        //register tap gesture recognizer
        self.registerHideKeyboardTappAround()
        
    }
    
//MARK: - Text View and Keyboard function
    deinit
    {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @IBAction func SignUpTapped(_ sender: Any)
    {
        guard let txtEmail = txtEmailSignUp.text,
            txtEmail != "",
            let txtPassword = txtPasswordSignUp.text,
            txtPassword != ""
            else{
                AlertController.showAlert(self, title: "Missing Fields", message: "Please enter in all fields")
                return
        }
		
		if txtPasswordSignUp.text != txtConfirmPasswordSignUP.text
		{
			AlertController.showAlert(self, title: "Password error", message: "Confirmation password does not mach given password")
			return
		}
        Auth.auth().createUser(withEmail: txtEmail, password: txtPassword, completion: {(user, error) in
            guard error == nil else
            {
                AlertController.showAlert(self, title: "Error", message: error!.localizedDescription)
                return
            }
			let fireDatbaseService = FireDatabaseService()
			fireDatbaseService.AddUserAccount(user: user!.user)
            self.sendEmailVerifcation(createdUser: user!.user)
            if let range = txtEmail.range(of: "@")
            {
                let username = txtEmail[txtEmail.startIndex..<range.lowerBound]
                let usernameString = String(username)
                let changeRequest = user?.user.createProfileChangeRequest()
                changeRequest?.displayName = usernameString
                changeRequest?.commitChanges(completion: { (error)  in
                    guard error == nil else
                    {
                        AlertController.showAlert(self, title: "Error", message: error!.localizedDescription)
                        return
                    }
                })
            }
        }
        )
    }
    
	@IBAction func cancelButtonWasTapped(_ sender: Any) {
		self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
		self.dismiss(animated: true, completion: nil)
	}
	
	//Kebboard Method
    @objc func KeyboardWillChange(notification: Notification)
    {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            else
        {
            return
        }
        if(notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification)
        {
            keyboardFrame = keyboardRect
            if(isViewUp == false)
            {
                view.frame.size.height = view.frame.size.height  + keyboardFrame.height
                
                let device:String = PhoneDetector.init().DetectDevice()
                
                if(device == "iPhone 5s or SE")
                {
                    view.frame.origin.y = -117
                }
                else
                {
                view.frame.origin.y = view.frame.origin.y - (keyboardFrame.height/3);
                }
                isViewUp = true;
                
            }
        }
        if(notification.name == UIResponder.keyboardWillHideNotification)
        {
            if(isViewUp)
            {
               /* let device:String = PhoneDetector.init().DetectDevice()
                
                if(device == "iPhone 5s or SE")
                {
                    view.frame.size.height = view.frame.size.height  - 200
                }
                else
                {
                    view.frame.size.height = view.frame.size.height  - 20
                }*/
                view.frame.size.height = view.frame.size.height  - keyboardFrame.height
                view.frame.origin.y = 0
                
                isViewUp = false
            }
        }
    }
	
    func resetFields()
	{
		txtPasswordSignUp.text = ""
		txtConfirmPasswordSignUP.text = ""
		txtEmailSignUp.text = ""
		signOut()
	}
	
	func signOut()
	{
		do
        {
            try Auth.auth().signOut()
        }
		catch _
        {
            return
        }
	}
	
	func sendEmailVerifcation(createdUser: User)
	{
		createdUser.sendEmailVerification(completion: {(error)
			in
			if (error != nil)
			{
				let alert = UIAlertController(title: "Email Verification Error", message:  "There was an error in sending the verficiation email. Please make sure that you are using an active email address.", preferredStyle: .alert)
				let okAction = UIAlertAction(title: "Ok", style: .default, handler: {action
					in
					self.resetFields()
				})
				alert.addAction(okAction)
				self.present(alert, animated: true, completion: nil)
				
			}
			else
			{
				let verifyAlert = UIAlertController(title: "Successful", message: "An email verification has been sent to the provided email. Please validate email before login. Make sure to check spam and junk folder for email verification.", preferredStyle: .alert)
				let verifyAction = UIAlertAction(title: "OK", style: .default, handler: {
					action
					in
					self.clearAndDismss()
				})
				verifyAlert.addAction(verifyAction)
				self.present(verifyAlert, animated: true, completion: nil)
			}
		})
	}
	
	func clearAndDismss()
	{
		resetFields()
		self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
		self.dismiss(animated: true, completion: nil)
	}
	
    //MARK: - UITextFieldDelegate Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return true
    }
    
}
