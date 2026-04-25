//
//  FlagTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 11/16/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit

class FlagTableViewController: UITableViewController {

    private enum FlagRow: Int {
        case falseReport = 2
        case offensiveLanguage = 3
        case encouragesViolence = 4
    }

    var doc : String!
    var incidentReport : IncidentReport!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        guard let flagRow = FlagRow(rawValue: indexPath.row) else { return }
        let question: String
        switch flagRow {
        case .falseReport:
            question = "What part of the report is false? Please provide details"
        case .offensiveLanguage:
            question = "What language in the report is being offensive?"
        case .encouragesViolence:
            question = "In what way is violence is being encouraged in the report?"
        }
        self.performSegue(withIdentifier: "FlagToSubmit", sender: question)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "FlagToGuide",
           let guideVC = segue.destination as? GuidePolicyViewController
        {
            guideVC.document = doc
        }
        else if segue.identifier == "FlagToSubmit",
                let flagVC = segue.destination as? FlagViewController,
                let question = sender as? String
        {
            flagVC.quest = question
            flagVC.incident = incidentReport
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

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
}
