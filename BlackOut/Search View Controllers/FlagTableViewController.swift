//
//  FlagTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/16/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit

class FlagTableViewController: UITableViewController {

    var doc : String!
    var question : String!
    var guideViewController : GuidePolicyViewController!
    var flagViewController: FlagViewController!
    var incidentReport : IncidentReport!
    
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
        return 6
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let row = indexPath.row
        
        if (row == 2)
        {
            question = "What part of the report is false? Please provide details"
            self.performSegue(withIdentifier: "FlagToSubmit", sender: self)
        }
        else if ( row == 3)
        {
            question = "What language in the report is being offensive?"
            self.performSegue(withIdentifier: "FlagToSubmit", sender: self)
            
        }
        else if (row == 4)
        {
            question = "In what way is violence is being encouraged in the report?"
            self.performSegue(withIdentifier: "FlagToSubmit", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "FlagToGuide")
        {
            guideViewController = segue.destination as? GuidePolicyViewController
            guideViewController.document = doc
        }
        else if (segue.identifier == "FlagToSubmit")
        {
            flagViewController = segue.destination as? FlagViewController
            flagViewController.quest = question
            flagViewController.incident = incidentReport
        }
    }
    
    @IBAction func DismissButtonTapped(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func ViewGuidelinessTapped(_ sender: Any)
    {
        doc = "ContentGuide"
        self.performSegue(withIdentifier: "FlagToGuide", sender: self)
    }
    
    //MARK: - Set Battery and Time to light
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

