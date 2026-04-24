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
	var flagViewTableViewController : FlagTableViewController!
	var commentTableViewController : CommentsTableViewController!
	
	@IBOutlet weak var commentCell: UITableViewCell!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        CompanyNameLabel.text = incident?.businessName
        addressLabel.text = incident?.businessLoaction
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
		if calendar.isDate(incident!.date, inSameDayAs: Date())
		{
			incidentDate?.text = Date().timeAgo(compare: incident!.date)
		}
		else
		{
			 incidentDate?.text = dateFormatter.string(from: incident!.date)
		}

		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
		commentCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, .greatestFiniteMagnitude)
		commentCell.layoutMargins = .zero
    }

	 override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		incidentDescription.selectedRange = NSMakeRange(0, 0)
	}
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }
	
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
        if(segue.identifier == "IncidentToFlag")
        {
            flagViewTableViewController = segue.destination as? FlagTableViewController
            flagViewTableViewController.incidentReport = incident;
        }
		else if (segue.identifier == "ShowComments")
		{
			commentTableViewController = segue.destination as? CommentsTableViewController
			commentTableViewController.postComment = incident?.descriptionMessage
			commentTableViewController.postDate = incidentDate.text
			commentTableViewController.postId = incident?.postId
			commentTableViewController.postUsername = incident?.username
			commentTableViewController.reportTitle = incident?.reportTitle
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
