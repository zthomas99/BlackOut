//
//  LaunchScreenViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/12/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
import WebKit
import FLAnimatedImage
import Firebase

class LaunchScreenViewController: UIViewController {
    @IBOutlet weak var launchGifView: FLAnimatedImageView!
    
    
	override func viewDidLoad() {
		super.viewDidLoad()
		let currentUser = CurrentUserStatus.shared.user
		self.launchGifView.animatedImage = FLAnimatedImage(gifResource: "LaunchSreenFade-Tween.gif")
		self.launchGifView.loopCompletionBlock = {( loopTime : UInt) -> Void in
			self.launchGifView.stopAnimating()
			
			if  Auth.auth().currentUser == nil
			{
				self.performSegue(withIdentifier: "LaunchToLogin", sender: self)
			}
			else
			{
				FireDatabaseService.shared.RetrieveCurrentUser(completion: {
					(error)
					in
					
					if error != nil
					{
						self.signOut()
						DispatchQueue.main.async {
							self.performSegue(withIdentifier: "LaunchToLogin", sender: self)
							AlertController.showAlert(self, title: "Launch Error", message: "Failed to retrieve user info please try to re-login.")
						}
						
						
					}
					else
					{
						DispatchQueue.main.async {
							self.performSegue(withIdentifier: "SplashToNavigation", sender: self)
						}
					}
				})
			}
		}
		
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
	
    //MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension FLAnimatedImage {
    convenience init(gifResource: String) {
        self.init(animatedGIFData: NSData(contentsOfFile:     Bundle.main.path(forResource: gifResource, ofType: "")!) as Data?)
    }
}
