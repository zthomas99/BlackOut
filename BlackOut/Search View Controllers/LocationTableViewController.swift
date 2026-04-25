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
    var searchReportTableViewController: SearchReportTableViewController?
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
			row = tapGesture.view?.tag ?? 0
		}

		let location = locations[row]
		businessPhotos = location.profilePhotos ?? []

        if segue.identifier == "LocationToReport",
           let reportVC = segue.destination as? SearchReportTableViewController
        {
			reportVC.incidents = location.incidentReports
			reportVC.locationName = location.businessName
			reportVC.businessPhotoNames = businessPhotos
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
		if location.hasMediaFiles, let mediaFiles = mediaList[location], mediaFiles.count > 0,
		   let headerCell = tableView.dequeueReusableCell(withIdentifier: "MediaCell") as? MediaLocationCell
		{
			headerCell.lblLocationTitle.text = location.businessName.uppercased()
			headerCell.imageList = mediaFiles
			headerCell.topMediaBtn.tag = section
			headerCell.bottomMediaBtn.tag = section
			headerCell.topMediaBtn.addTarget(self, action: #selector(didSelectSection(sender:)), for: .touchUpInside)
			headerCell.bottomMediaBtn.addTarget(self, action: #selector(didSelectSection(sender:)), for: .touchUpInside)
			headerCell.lblAddress.text = location.businessLocation
			headerCell.lblReportCount.text = "\(location.incidentReports.count) \(location.incidentReports.count > 1 ? "reports" : "report")"
			headerCell.imageCollectionView.tag = section
			headerCell.imageCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didSelectSection(sender:))))
			return headerCell
		}
		guard let noMediaCell = tableView.dequeueReusableCell(withIdentifier: "NoMediaCell") as? NoMediaTableViewCell else { return nil }
		noMediaCell.lblLocationTitle.text = location.businessName.uppercased()
		noMediaCell.lblAddress.text = location.businessLocation
		noMediaCell.btnSelect.tag = section
		noMediaCell.btnSelect.addTarget(self, action: #selector(didSelectSection(sender:)), for: .touchUpInside)
		noMediaCell.lblNumberOfReports.text = "\(location.incidentReports.count) \(location.incidentReports.count > 1 ? "reports" : "report")"
		return noMediaCell
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
		guard let parentVC = self.parent else { return }
		if spinnerView == nil {
			spinnerView = SpinnerViewController()
		}
		guard let spinner = spinnerView else { return }
		parentVC.addChildViewController(spinner)
		spinner.view.frame = parentVC.view.frame
		parentVC.view.addSubview(spinner.view)
		spinner.didMove(toParentViewController: parentVC)
	}

	func removeSpinner()
	{
		guard let spinner = spinnerView else { return }
		spinner.willMove(toParentViewController: nil)
		spinner.view.removeFromSuperview()
		spinner.removeFromParentViewController()
		spinnerView = nil
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
