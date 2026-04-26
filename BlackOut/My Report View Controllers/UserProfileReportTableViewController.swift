//
//  UserProfileReportTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/14/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit
import FirebaseAuth
class UserProfileReportTableViewController: UITableViewController {

    var reports = [IncidentReport]()
	 var commentStatMap = [String: CommentMetadata]()
	 var username : String?
	 var tappedReport : IncidentReport?
	 
	 
	 override func viewDidLoad() {
		 super.viewDidLoad()
		 tableView.tableFooterView = UIView()
		 tableView.estimatedSectionHeaderHeight = 350
	 }

	 override func viewWillAppear(_ animated: Bool) {
		 super.viewWillAppear(true)
		 if username == nil
		 {
			 username = "unknown"
		 }
		 let fireDatabaseService = FireDatabaseService()
		 fireDatabaseService.retrieveReports(withUser: username!, completion: { [weak self] reports in
			 Task { @MainActor in
				 guard let self = self else { return }
				 self.reports = reports
				 if self.reports.count > 0
				 {
					 FireDatabaseService.shared.retrieveCommentMetadata(withReports: reports, completion: { [weak self] data in
						 Task { @MainActor in
							 guard let self = self else { return }
							 self.commentStatMap = data
							 self.tableView.reloadData()
						 }
					 })
				 }
				 else
				 {
					 self.tableView.reloadData()
				 }
			 }
		 })
	 }
	 // MARK: - Table view data source

	 override func numberOfSections(in tableView: UITableView) -> Int {
		if reports.count == 0
				{
					tableView.backgroundView = nil
					let noDataLabel : UILabel = UILabel(frame: CGRect(x: 0,y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
					noDataLabel.text = "No Reports found for \(String(describing: username ?? "unkown"))"
					noDataLabel.textColor = UIColor.white
					noDataLabel.textAlignment = NSTextAlignment.center
					tableView.backgroundView = noDataLabel
					return 1
				}
		tableView.backgroundView = nil
		return reports.count + 1
	 }

	 override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0
		{
			return 0
			
		}
		 return 1
	 }

	 override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		if section == 0
		{
			let reportTitleCell = tableView.dequeueReusableCell(withIdentifier: "ProfileReportTitle") as? ProfileReportTitleCell
			if username == nil
			{
				username = Auth.auth().currentUser?.displayName
			}
			reportTitleCell?.lblUserAccount.text = "\(String(describing:username ?? "unknown"))'s"
			return reportTitleCell?.contentView
		}
		else
		{
			let index = section - 1
			let report = reports[index]
			let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileReport", for: IndexPath(row: 0, section: section)) as? UserProfileReportCell
			cell?.lblReportDescription.text = report.descriptionMessage
			cell?.contentView.tag = index
			cell?.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewReportButtonTapped(sender:))))
			cell?.lblReportTitle.text = report.reportTitle
			cell?.canvasView.dropShadow(color: UIColor.black)
			return cell?.contentView
		}
	 }
	
	 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let index = indexPath.section - 1
		let report = reports[index]
		let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationTableViewCell", for: indexPath) as? NavigationTableViewCell
		// add button targets
		cell?.btnReport.tag = index
		cell?.btnReport.addTarget(self, action: #selector(ViewReportButtonTapped(sender:)), for: .touchUpInside)
		
		cell?.btnComment.tag = index
		cell?.btnComment.addTarget(self, action: #selector(ViewCommentsButtonTapped(sender:)), for: .touchUpInside)
		if commentStatMap[report.postId] != nil
		{
			cell?.lblCommentCount.text = " \(String(describing: commentStatMap[report.postId]?.adviceCount ?? 0)) advices \(String(describing: commentStatMap[report.postId]?.commentCount ?? 0)) comments"
		}
		else
		{
			cell?.lblCommentCount.text = "0 advices 0 comments"
		}
		return cell!
	 }
	 
	 override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		 return UITableView.automaticDimension
	 }
	 
	 override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		 return UITableView.automaticDimension
	 }
	 
	 override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 46.0
	 }
	 
	 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		 if(segue.identifier == "ShowComments")
		 {
			 let commentView = (segue.destination as? CommentsTableViewController)
			 
			 //format date to string
			 let dateFormatter = DateFormatter()
			 dateFormatter.dateStyle = .medium
			 dateFormatter.timeZone = .none
			 dateFormatter.locale = Locale(identifier: "en_US")
			 let dateString = dateFormatter.string(from: tappedReport!.date)
			 
			 //initialize properties for comment table view controller
			 commentView!.postComment = tappedReport!.descriptionMessage
			 commentView!.postDate = dateString
			 commentView!.postId = tappedReport!.postId
			 commentView!.postUsername = tappedReport!.username
			 commentView!.reportTitle = tappedReport!.reportTitle
		 }
		 else if segue.identifier == "ShowIncidentView"
		 {
			 let incidentView = segue.destination as? IncidentViewController
			 incidentView?.incident = tappedReport
		 }
	 }
	 
	 override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		 
		 tableView.deselectRow(at: indexPath, animated: false)
		 let row = indexPath.row
		 let report = reports[row]
		 tappedReport = report
		 self.performSegue(withIdentifier: "ShowIncidentView", sender: self)
	 }
	 
	@IBAction func CancelButtonWasTapped(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}
	@objc func ViewReportButtonTapped(sender: Any)
	 {
		var row : Int = 0
		var report : IncidentReport?
		if let button = sender as? UIButton
		{
			row  = button.tag
			report = reports[row]
			tappedReport = report
		}
		
		if let gesture = sender as? UITapGestureRecognizer
		{
			row = gesture.view!.tag
			report = reports[row]
			tappedReport = report
		}
		self.performSegue(withIdentifier: "ShowIncidentView", sender: self)
	 }
	 
	 @objc func ViewCommentsButtonTapped(sender: Any)
	 {
		 let button = sender as? UIButton
		 let row = button?.tag
		 let report = reports[row!]
		 tappedReport = report
		 self.performSegue(withIdentifier: "ShowComments", sender: self)
	 }

	 //MARK: - Set Battery and Time to White
	 override var preferredStatusBarStyle: UIStatusBarStyle
	 {
		 return .lightContent
	 }
}
