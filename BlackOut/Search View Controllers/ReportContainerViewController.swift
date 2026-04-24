//
//  ReportContainerViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 1/1/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class ReportContainerViewController: UIViewController {
    
    var reports:[String]?
    var locationName : String?
    var businessPhotoFileNames : [String] = []
    
    
    var searchReportTableView:SearchReportTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
		// Do any additional setup after loading the view.
    }
    
	func RetrievewBusinessPhotos()
    {
        for incident in reports!
		{
            let busPhotoRef = FireDatabaseService.shared.incidentReference.child(incident).child("businessPhoto")
            busPhotoRef.observeSingleEvent(of: .value, with: {(snapshot) in
                
                let fileName = snapshot.value as? String
                if(fileName != "default.JPG")
                {
					DispatchQueue.main.async {
						self.businessPhotoFileNames.append(fileName!)
					}
                }
            })
        }
    }
	

	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "EmbedSearchReportTable")
        {
            searchReportTableView = segue.destination as? SearchReportTableViewController
            searchReportTableView?.incidents = reports
			searchReportTableView?.locationName = locationName
			searchReportTableView?.businessPhotoNames = businessPhotoFileNames
        }
    }
    
	//MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
}
