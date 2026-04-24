//
//  SlimIncidentViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/5/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit
import FirebaseStorage
import AVFoundation
import AVKit
import QuartzCore

class SlimIncidentViewController: UIViewController, UITextViewDelegate{
   
    //MARK: - Outlet variables
    @IBOutlet var navigationView: UIImageView!
    @IBOutlet var incidentScrollView: UIScrollView!
	@IBOutlet weak var doneButton: UIButton!
	@IBOutlet weak var backgroundView: UIImageView!
	
    //MARK: - Variables
    var incident:IncidentReport?
    var storage:FireStorage = FireStorage()
    var detailsTableViewController : IncidentDetailsTableViewController?
    var videoController : VideoViewController?
    var imageViewList = [UIImageView]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(incident?.businessPhoto != "default.JPG")
        {
            storage.mediaReference.child((incident?.businessPhoto)!).getData(maxSize: 10 * 1000 * 1000) { (Data, Error) in
				if(Error == nil)
				{
					let backgroundImage:UIImage = UIImage(data: Data!)!
					self.navigationView.image = backgroundImage
					self.navigationView.contentMode = .scaleAspectFit
					self.backgroundView.image = backgroundImage
					self.backgroundView.contentMode = .scaleAspectFill
					self.backgroundView.addBlurToView()
				}
                else
                {
                    print(Error?.localizedDescription)
                }
            }
        }
        else
        {
			navigationView.contentMode = .scaleAspectFit
			navigationView.backgroundColor = .black
         navigationView.image = UIImage(named: "NavigationView.png")
        }
		doneButton.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    //Mark: Navigation Function

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "SlimIncidentViewToIncidentDetails")
        {
            detailsTableViewController = segue.destination as? IncidentDetailsTableViewController
            detailsTableViewController?.incident = incident
        }

    }
    
    @IBAction func DoneButtonHasBeenTapped(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Set Battery and Time to White
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

}
