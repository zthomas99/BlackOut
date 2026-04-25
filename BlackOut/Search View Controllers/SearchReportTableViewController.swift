//
//  SearchReportTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 10/29/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import Firebase

class SearchReportTableViewController: UITableViewController {

    var reports = [IncidentReport]()
    var storage:FireStorage = FireStorage()
    var incidents:[String]?
    var selectedReport: IncidentReport?
    var isFirstSearch : Bool = true
	var locationName : String?
	var businessPhotoNames : [String]?

	
	@IBOutlet weak var headerImageView: UIImageView!
	@IBOutlet weak var businessNameLabel: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
		tableView.contentInset = .zero
		businessNameLabel.text = locationName
        retrieveReports()
        headerImageView.addBlurToView()
		downloadNavigationImage()
	}

    func retrieveReports()
    {
        guard let incidents = incidents else { return }
        for incident in incidents
        {
            FireDatabaseService.shared.incidentReference.child(incident).observeSingleEvent(of: .value)
            {
                (snapshot, err) in
                
                if(err != nil)
                {
                    print("The following error occurred quering inicident: \(incident) error: \(String(describing: err))")
                }
                else if(snapshot.exists())
                {
                    guard let snapConverter =  SnapToIncidentReport.init(with: snapshot)
                        else
                    {
                        print("Failed to convert incident snapshot for the following incident \(incident)")
                        return
                    }
                    DispatchQueue.main.async
                    {
                        self.reports.append(snapConverter.report)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        self.tableView.backgroundView = nil
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     return   UITableViewAutomaticDimension
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }

	@IBAction func BackButtonTapped(_ sender: Any) {
		businessPhotoNames?.removeAll()
		self.dismiss(animated: true, completion: nil)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as! ReportTableViewCell
        cell.selectionStyle = .none
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        
        cell.reportDescriptionLabel.text = reports[indexPath.row].descriptionMessage
		cell.titleLabel.text = reports[indexPath.row].reportTitle.uppercased()
        cell.userNameLabel.text = reports[indexPath.row].username
		
		let calendar = Calendar.current
		if calendar.isDate(reports[indexPath.row].date, inSameDayAs: Date())
		{
			cell.datePostedLabel.text = Date().timeAgo(compare: reports[indexPath.row].date)
		}
		else
		{
			cell.datePostedLabel.text = dateFormatter.string(from: reports[indexPath.row].date)
		}
		cell.separatorInset = UIEdgeInsetsMake(20, 20, 20, 20)
        return cell
    }

	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 350
	}
	
	func downloadNavigationImage()
	{
		guard let businessPhotoNames = businessPhotoNames, businessPhotoNames.count > 0 else { return }
		let number = Int.random(in: 0 ..< businessPhotoNames.count)
		let fileName = businessPhotoNames[number]
		storage.mediaReference.child(fileName).getData(maxSize: 1 * 100000 * 100000, completion: {(data, error) in
			if let error = error {
				print("The following error was thrown when attempting to download \(fileName) error: \(error.localizedDescription)")
				return
			}
			guard let data = data, let image = UIImage(data: data) else { return }
			DispatchQueue.main.async {
				self.headerImageView.image = image
			}
		})
	}
	
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
		selectedReport = reports[indexPath.row]
		self.performSegue(withIdentifier: "SearchTableToIncidentView", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "SearchTableToIncidentView",
           let incidentView = segue.destination as? IncidentViewController
        {
            incidentView.incident = selectedReport
        }
    }

}
