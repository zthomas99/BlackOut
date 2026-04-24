//
//  TermsViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/20/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import WebKit

class TermsViewController: UIViewController {
    @IBOutlet weak var termWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     let termURLString = "https://app.termly.io/document/terms-of-use-for-website/bd2f56f3-aeca-47e3-aef3-95a1601fe61b"
        let request = URLRequest(url: URL(string: termURLString)!)
     termWebView.load(request)
    }
    

    @IBAction func AgreeTapped(_ sender: Any)
    {
        self.performSegue(withIdentifier: "TermsToSignUp", sender: nil)
    }
    
    @IBAction func DisagreeTapped(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
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
