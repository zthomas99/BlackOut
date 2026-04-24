//
//  SettingsTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/15/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var txtCurrentPsswrd: UITextField!
    @IBOutlet var txtNewPsswrd: UITextField!
    @IBOutlet var txtConfirmPsswrd: UITextField!
    @IBOutlet var txtNewEmail: UITextField!
    @IBOutlet var changePsswdBtn: UIButton!
    @IBOutlet var changeEmailBtn: UIButton!
    @IBOutlet var signOutBtn: UIButton!
    
    var guidePolViewController: GuidePolicyViewController!
    var doc:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //register tap gesture recognizer
        self.registerHideKeyboardTappAround()
        changePsswdBtn.layer.cornerRadius = 20
		changePsswdBtn.dropShadow(color: UIColor.black)
        
        changeEmailBtn.layer.cornerRadius = 20
		changeEmailBtn.dropShadow(color: UIColor.black)
		
        signOutBtn.layer.cornerRadius = 20
		signOutBtn.dropShadow(color: UIColor.black)
		
        txtCurrentPsswrd.delegate = self
        txtNewPsswrd.delegate = self
        txtConfirmPsswrd.delegate = self
        txtNewEmail.delegate = self
        
    }

	//MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		if let headerView = view as? UITableViewHeaderFooterView{
			headerView.textLabel?.textColor = UIColor(red: 0.99, green: 0.80, blue: 0.00, alpha: 1.00)
		}
	}
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return 3
        }
        else if(section == 1)
        {
           return 4
            
        }
        else if (section == 2)
        {
            return 3
        }
        else if (section == 3)
        {
            return 1
        }
        return 0
    }
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let section = indexPath.section
		
		if(section != 0)
		{
			cell.selectionStyle = .none
		}
		else
		{
			cell.selectionStyle = .default
		}
	}
 override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = indexPath.row
		let section = indexPath.section
		if row == 0 && section == 0
		{
			doc = "ContentGuide"
			self.performSegue(withIdentifier: "SettingToGuidePolicy", sender: self)
		}
		else if row == 1 && section == 0
		{
			doc = "PrivacyPolicy"
			self.performSegue(withIdentifier: "SettingToGuidePolicy", sender: self)
		}
		else if row == 2 && section == 0
		{
			self.performSegue(withIdentifier: "ShowBlockedAccounts", sender: self)
		}
	tableView.deselectRow(at: indexPath, animated: false)
	}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "SettingToGuidePolicy")
        {
            //searchTableViewController = segue.destination as? SearchReportTableViewController
            guidePolViewController = segue.destination as? GuidePolicyViewController
            guidePolViewController.document = doc
        }
    }
	
	@IBAction func SignOutWasTapped(_ sender: Any) {
		logOut(completion: {
			(success,error)
			in
			
			if error != nil
			{
				AlertController.showAlert(self, title: "Failed logout", message: "There was a failure to log out, please try again.")
			}
			else
			{
				self.performSegue(withIdentifier: "SettingToMain", sender: nil)
			}
		})
	}
	
func logOut(completion: @escaping(_ successfull: Bool, _ error : Error?) -> Void)
{
	let auth = Auth.auth()
	do
	{
		try auth.signOut()
	} catch let signOutError as NSError
	{
		completion(false,signOutError)
	}
	completion(true, nil)
}

    @IBAction func ChangePasswordTapped(_ sender: Any)
    {
        if(txtCurrentPsswrd.text == "")
        {
            AlertController.showAlert(self, title: "Change Password Error", message: "Please fill in the current password")
            return
        }
        
        if(txtNewPsswrd.text == "")
        {
            AlertController.showAlert(self, title: "Change Password Error", message: "Please fill in the new password")
            return
        }
        
        if(txtConfirmPsswrd.text == "")
        {
           AlertController.showAlert(self, title: "Change Password Error", message: "Please fill in the confirm password")
            return
        }
        
        if(txtConfirmPsswrd.text != txtNewPsswrd.text)
        {
            AlertController.showAlert(self, title: "Change Password Error", message: "Current password and new password field does not match")
            return
        }
        
        let currentPassword = txtCurrentPsswrd.text
        let currentUser = Auth.auth().currentUser
        let password:String = txtNewPsswrd.text!
        
        Auth.auth().signIn(withEmail: (currentUser?.email)!, password: currentPassword!) { (results, error) in
            if(error == nil)
            {
                currentUser?.updatePassword(to: password, completion: {(error) in
                   if(error == nil)
                   {
                        AlertController.showAlert(self, title: "Success Password Change", message: "Password was successfully changed")
                        self.txtConfirmPsswrd.text = ""
                        self.txtNewPsswrd.text = ""
                        self.txtCurrentPsswrd.text = ""
                   }
                   else
                   {
                    AlertController.showAlert(self, title: "Password Update Error", message: (error?.localizedDescription)!)
                   }
                })
            }
            else
            {
                AlertController.showAlert(self, title: "Authentication Error", message: (error?.localizedDescription)!)
                return
            }
        }
    }
   
    @IBAction func ChangeEmailTapped(_ sender: Any)
    {
        if(txtNewEmail.text == "")
        {
            AlertController.showAlert(self, title: "Email Update Error", message: "Please fill in new email field")
            return
        }
        
        let currentUser = Auth.auth().currentUser
        let email:String = txtNewEmail.text!
        
        currentUser?.updateEmail(to: email, completion: { (Error) in
            if(Error == nil)
            {
                AlertController.showAlert(self, title: "Email Update Success", message: "Email changed successfully")
                self.txtNewEmail.text = ""
            }
            else
            {
                AlertController.showAlert(self, title: "Email Update Error", message: (Error?.localizedDescription)!)
            }
        })
    }
    

	@IBAction func ContentGuideWasTapped(_ sender: Any)
    {
        doc = "ContentGuide"
        self.performSegue(withIdentifier: "SettingToGuidePolicy", sender: self)
    }
    
    @IBAction func PrivacyPolicyWasTapped(_ sender: Any)
    {
        doc = "PrivacyPolicy"
        self.performSegue(withIdentifier: "SettingToGuidePolicy", sender: self)
    }
    
    //MARK: - UITextFieldDelegate Functions
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }
    
}
