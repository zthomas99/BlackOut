//
//  IncidentDetailsTableTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/24/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit

class IncidentDetailsTableViewController: UITableViewController{
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var CompanyNameLabel: UILabel!
    @IBOutlet weak var incidentUsername: UILabel!
    @IBOutlet weak var incidentDate: UILabel!
    @IBOutlet weak var incidentDescription: UITextView!
	@IBOutlet weak var lblReplyCount: UILabel!
	@IBOutlet weak var lblReportTitle: UILabel!
	
	var incident : IncidentReport?
	
	@IBOutlet weak var commentCell: UITableViewCell!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        CompanyNameLabel.text = incident?.businessName
        addressLabel.text = incident?.businessLocation
        incidentDescription.text = incident?.descriptionMessage
        incidentUsername.text = incident?.username
		lblReportTitle.text = incident?.reportTitle.uppercased()
		let replyCount : String = String(describing: incident?.replyCount ?? 0)
		lblReplyCount.text = replyCount
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeZone = .none
        dateFormatter.locale = Locale(identifier: "en_US")
		
		let calendar = Calendar.current
		if let incidentDate = incident?.date {
			if calendar.isDate(incidentDate, inSameDayAs: Date())
			{
				self.incidentDate?.text = Date().timeAgo(compare: incidentDate)
			}
			else
			{
				self.incidentDate?.text = dateFormatter.string(from: incidentDate)
			}
		}

		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
		tableView.estimatedRowHeight = 100
		commentCell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
		commentCell.layoutMargins = .zero
    }

	 override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		incidentDescription.selectedRange = NSRange(location: 0, length: 0)
	}
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 4 {
            return UITableView.automaticDimension
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "IncidentToFlag",
           let flagVC = segue.destination as? FlagTableViewController
        {
            flagVC.incidentReport = incident
        }
		else if segue.identifier == "ShowComments",
		        let commentVC = segue.destination as? CommentsTableViewController
		{
			commentVC.postComment = incident?.descriptionMessage
			commentVC.postDate = incidentDate.text
			commentVC.postId = incident?.postId
			commentVC.postUsername = incident?.username
			commentVC.reportTitle = incident?.reportTitle
		}
    }
	@IBAction func CommentButtonTapped(_ sender: Any) {
		self.performSegue(withIdentifier: "ShowComments", sender: self)
	}
	
    @IBAction func FlaggedButtonTapped(_ sender: Any)
    {
        self.performSegue(withIdentifier: "IncidentToFlag", sender: nil)
        
    }

}
