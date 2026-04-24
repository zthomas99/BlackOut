//
//  SubReplyTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/24/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class SubReplyTableViewController: UITableView{

	var replies : [Reply]?
	var addReplyTableViewController : AddReplyTableViewController?
	var selectReply : Reply?
	var postId : String!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
		return replies!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as? ReplyCell
		let row = indexPath.row
        // Configure the cell...
		cell!.replyBtn.tag = row
		cell!.replyBtn.addTarget(self, action: #selector(AddReplyButtonTapped(sender:)), for: .touchUpInside)
		cell!.lblUsername.text = replies?[row].user
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeZone = .none
		dateFormatter.locale = Locale(identifier: "en_US")
		cell!.lblDate.text = dateFormatter.string(from: (replies?[row].date)!)
		cell!.backView.layer.cornerRadius = cell!.backView.frame.height/30
		cell!.textViewComment.text = replies?[row].comment
		return cell!
    }
    
	@objc func AddReplyButtonTapped(sender: UIButton)
	{
		let row = sender.tag
		
		selectReply = replies![row]
		
		self.performSegue(withIdentifier: "ShowAddReply", sender: nil)
	}

	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "ShowAddReply" && selectReply != nil
		{
			addReplyTableViewController = segue.destination as? AddReplyTableViewController
			addReplyTableViewController?.isReplyToAdvice = false
			addReplyTableViewController?.reply = selectReply
			addReplyTableViewController?.postId = postId
		}
	}
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
