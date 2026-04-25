//
//  ProfileReportTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/12/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileReportTableViewController: UITableViewController {

	var reports = [IncidentReport]()
	var commentStatMap = [String: CommentMetadata]()
	var username : String?
	var tappedReport : IncidentReport?
	var refresh: UIRefreshControl?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		refresh = UIRefreshControl()
		tableView.tableFooterView = UIView()
		tableView.estimatedSectionHeaderHeight = 350
		tableView.refreshControl = refresh
		tableView.refreshControl?.tintColor = UIColor.white
		tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Reloading My Reports...")
		tableView.refreshControl?.addTarget(self, action: #selector(RefreshTable), for: .valueChanged)
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		username = UserAccount.shared?.username
		RefreshTable()
	}
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if reports.count == 0
		{
			tableView.backgroundView = nil
			let noDataLabel : UILabel = UILabel(frame: CGRect(x: 0,y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
			noDataLabel.text = "No Reports found for \(String(describing: username ?? "unkown"))"
            noDataLabel.textColor = UIColor.white
            noDataLabel.textAlignment = NSTextAlignment.center
			tableView.backgroundView = noDataLabel
			return 0
		}
		tableView.backgroundView = nil
		return reports.count
    }

	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let reportTitleCell = tableView.dequeueReusableCell(withIdentifier: "ProfileReportTitle") as? ProfileReportTitleCell
		if username == nil
		{
			username = Auth.auth().currentUser?.displayName
		}
		reportTitleCell?.lblUserAccount.text = "\(String(describing:username ?? "unknown"))'s"
		return reportTitleCell?.contentView
	}
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		let report = reports[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileReport", for: indexPath) as? ProfileReportCell
		cell?.lblReportDescription.text = report.descriptionMessage
		cell?.lblReportTitle.text = report.reportTitle.uppercased()
		cell?.contentView.dropShadow(color: UIColor.black)
		// add button targets
		cell?.btnReport.tag = row
		cell?.btnReport.addTarget(self, action: #selector(ViewReportButtonTapped(sender:)), for: .touchUpInside)
		
		cell?.btnComment.tag = row
		cell?.btnComment.addTarget(self, action: #selector(ViewCommentsButtonTapped(sender:)), for: .touchUpInside)
		
		cell?.btnEdit.tag = row
		cell?.btnEdit.addTarget(self, action: #selector(EditButtonWasTapped(sender:)), for: .touchUpInside)
		if commentStatMap[report.postId] != nil
		{
			cell?.lblCommentCount.text = " \(String(describing: commentStatMap[report.postId]?.adviceCount ?? 0)) advices \(String(describing: commentStatMap[report.postId]?.commentCount ?? 0)) comments"
		}
		else
		{
			cell?.lblCommentCount.text = "0 advices 0 comments"
		}
		cell?.dropShadow(color: UIColor.black)
        return cell!
    }
    
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return 300.0
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
		else if (segue.identifier == "ShowReportEdit")
		{
			let editReportController = segue.destination as? EditReportViewController
			let button = sender as? UIButton
			let row = button?.tag
			let selectedReport = reports[row!]
			editReportController?.report = selectedReport
		}
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: false)
		let row = indexPath.row
		let report = reports[row]
		tappedReport = report
		self.performSegue(withIdentifier: "ShowIncidentView", sender: self)
	}

	@objc func RefreshTable()
	{
		let fireDatabaseService = FireDatabaseService()
		fireDatabaseService.RetrieveReports(withUser: username!, completion: {
			(reports)
			in
			self.reports = reports
			if self.reports.count > 0
			{
				FireDatabaseService.shared.RetrieveCommentMetadata(withReports: reports, completion: {
					(data)
					
					in
					self.commentStatMap = data
					DispatchQueue.main.async {
						self.refresh?.endRefreshing()
						self.tableView.reloadData()
					}
				})
			}
			else
			{
				DispatchQueue.main.async {
					self.refresh?.endRefreshing()
					self.tableView.reloadData()
				}
			}
		})
	}
	
	@objc func EditButtonWasTapped(sender: Any)
	{
		self.performSegue(withIdentifier: "ShowReportEdit", sender: sender)
	}
	
	@objc func ViewReportButtonTapped(sender: Any)
	{
		let button = sender as? UIButton
		let row  = button?.tag
		let report = reports[row!]
		tappedReport = report
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
