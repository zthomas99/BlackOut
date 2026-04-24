//
//  GuidePolicyViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/30/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import WebKit

class GuidePolicyViewController: UIViewController {

    var document:String!
	@IBOutlet weak var navigationView: UIView!
	@IBOutlet var guidePolicyWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		navigationView.addBlurToView()
        var termURLString:String!
        if(document == "ContentGuide")
        {
            termURLString = "https://www.fervorware.com/blackout-conduct"
        }
        else
        {
            termURLString = "https://www.fervorware.com/blackout-privacy.html"
        }
        
        let request = URLRequest(url: URL(string: termURLString)!)
        guidePolicyWebView.load(request)
        
    }
    
    
    @IBAction func GudiePolicyBackTapped(_ sender: Any)
    {
        //self.performSegue(withIdentifier: "GuidePolicyToSettings", sender: nil)
      self.dismiss(animated: true, completion: nil)
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
