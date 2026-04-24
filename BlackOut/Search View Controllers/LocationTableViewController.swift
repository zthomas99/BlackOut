//
//  LocationViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/24/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore
import AVFoundation
import AVKit
import QuartzCore


class LocationTableViewController: UITableViewController {

    var isFirstSearch : Bool = true
    var locations = [LocationReport]()
    var reportViewContainer: ReportContainerViewController?
    var locationName : String?
    var incidents:[String]?
    var businessPhotos: [String] = []
	var mediaList = [LocationReport: [String]]()
	var spinnerView : SpinnerViewController?
	
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
		tableView.estimatedSectionHeaderHeight = 300
    }
    	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		var row : Int = 0
		if let button = sender as? UIButton
		{
			row = button.tag
		}
	
		if let tapGesture = sender as? UITapGestureRecognizer
		{
			row = tapGesture.view!.tag
		}
		
		let location = locations[row]
		
		if location.profilePhotos != nil
		{
			businessPhotos = location.profilePhotos!
		}
		else
		{
			businessPhotos = []
		}
		
        if(segue.identifier == "LocationToReport")
        {
            reportViewContainer = segue.destination as? ReportContainerViewController
			reportViewContainer?.reports = location.incidentReports
			reportViewContainer?.locationName = location.businessName
			reportViewContainer?.businessPhotoFileNames = businessPhotos
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
		
		let noDataLabel : UILabel = UILabel(frame: CGRect(x: 0,y: 0, width: self.tableView.bounds.width, height: tableView.bounds.height))
		noDataLabel.text = "No Results Found"
		noDataLabel.textColor = UIColor.white
		noDataLabel.textAlignment = NSTextAlignment.center
		
		let firstSearchLabel : UILabel = UILabel(frame: CGRect(x: 0,y: 0, width: self.tableView.bounds.width, height: tableView.bounds.height))
		firstSearchLabel.text = "Enter a city, state, or zip code  above to search for reports"
		firstSearchLabel.textColor = UIColor.white
		firstSearchLabel.textAlignment = NSTextAlignment.center
		firstSearchLabel.numberOfLines = 3
		
		if(locations.count == 0)
		{
			if(isFirstSearch)
			{
				tableView.backgroundView = firstSearchLabel
				
			}
			else
			{
				tableView.backgroundView = noDataLabel
			}
			return 0
		}
		else
		{
			tableView.backgroundView = nil
			return locations.count
		}
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let location = locations[section]
		if location.hasMediaFiles && mediaList[location] != nil && mediaList[location]!.count > 0
		{
			let headerCell = tableView.dequeueReusableCell(withIdentifier: "MediaCell") as? MediaLocationCell
			headerCell?.lblLocationTitle.text = location.businessName.uppercased()
			headerCell?.imageList = mediaList[location]!
			headerCell?.topMediaBtn.tag = section
			headerCell?.bottomMediaBtn.tag = section
			headerCell?.topMediaBtn.addTarget(self, action: #selector(didSelectSection(sender:)), for: .touchUpInside)
			headerCell?.bottomMediaBtn.addTarget(self, action: #selector(didSelectSection(sender:)), for: .touchUpInside)
			headerCell?.lblAddress.text = location.businessLocation
			headerCell?.lblReportCount.text = "\(String(describing: location.incidentReports.count )) \( (location.incidentReports.count > 1 ) ? " reports" : " report")"
			headerCell?.imageCollectionView.tag = section
			headerCell?.imageCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectSection(sender:))))
			return headerCell!
		}
		let noMediaCell = tableView.dequeueReusableCell(withIdentifier: "NoMediaCell") as? NoMediaTableViewCell
		noMediaCell?.lblLocationTitle.text = location.businessName.uppercased()
		noMediaCell?.lblAddress.text = location.businessLocation
		noMediaCell?.btnSelect.tag = section
		noMediaCell?.btnSelect.addTarget(self, action: #selector(didSelectSection(sender:)), for: .touchUpInside)
		noMediaCell?.lblNumberOfReports.text = "\(String(describing: location.incidentReports.count )) \( (location.incidentReports.count > 1 ) ? " reports" : " report")"
		return noMediaCell!
	}
	
	
	@objc func didSelectSection(sender: Any)
	{
		self.performSegue(withIdentifier: "LocationToReport", sender: sender)
	}
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 200
	}
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let row = indexPath.row
		print(row)
    }
    
// MARK: - Spinner Functions
	func createSpinner()
	{
		if spinnerView == nil
		{
			spinnerView = SpinnerViewController()
			self.parent!.addChildViewController(spinnerView!)
			spinnerView!.view.frame = self.parent!.view.frame
			self.parent!.view.addSubview(spinnerView!.view)
			spinnerView?.didMove(toParentViewController: self.parent!)
		}
		else
		{
			self.parent!.addChildViewController(spinnerView!)
			spinnerView!.view.frame = self.parent!.view.frame
			self.parent!.view.addSubview(spinnerView!.view)
			spinnerView?.didMove(toParentViewController: self.parent!)
		}
	}
	
	func removeSpinner()
	{
		if spinnerView != nil
		{
			spinnerView?.willMove(toParentViewController: nil)
			spinnerView?.view.removeFromSuperview()
			spinnerView?.removeFromParentViewController()
			spinnerView = nil
		}
	}
	
// MARK: - Download Functions
	func downloadReports()
	{
		createSpinner()
		mediaList.removeAll()
		businessPhotos.removeAll()
		if locations.count > 0
		{
			var locationCounter = 0
			let locationCount = locations.count
			for location in locations
			{
				if location.hasMediaFiles
				{
					let fireDatabaseService = FireDatabaseService()
					fireDatabaseService.RetrieveMediaList(location: location, completion: {
						(mediaList)
						in
						self.mediaList[location] = mediaList
						locationCounter += 1
						
						if locationCounter == locationCount
						{
							DispatchQueue.main.async {
								self.removeSpinner()
								self.tableView.reloadData()
							}
						}
					})
				}
				else
				{
					locationCounter += 1
					if locationCounter == locationCount
					{
						DispatchQueue.main.async {
							self.removeSpinner()
							self.tableView.reloadData()
						}
					}
				}
			}
		}
		else
		{
			DispatchQueue.main.async {
				self.removeSpinner()
				self.tableView.reloadData()
			}
		}
	}
}
