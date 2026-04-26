//
//  BlockedAccountTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/16/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit

class BlockedAccountTableViewController: UITableViewController {

	var blockedUsers = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.estimatedSectionHeaderHeight = 350
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let fireDatabaseService = FireDatabaseService()
		fireDatabaseService.retrieveBlockedUsers(completion: { [weak self] users in
			Task { @MainActor in
				self?.blockedUsers = users
				self?.tableView.reloadData()
			}
		})
	}
    // MARK: - Table view data source
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerCell = tableView.dequeueReusableCell(withIdentifier: "BlockedHeaderCell") as? BlockedHeaderCell
		headerCell?.btnCancel.addTarget(self, action: #selector(CancelButtonWasTapped(sender:)), for: .touchUpInside)
		return headerCell?.contentView
	}
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if blockedUsers.count == 0
		{
			tableView.backgroundView = nil
			let noDataLabel : UILabel = UILabel(frame: CGRect(x: 0,y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
            noDataLabel.text = "You have no blocked users currently."
            noDataLabel.textColor = UIColor.white
            noDataLabel.textAlignment = NSTextAlignment.center
			tableView.backgroundView = noDataLabel
			return 0
		}
		tableView.backgroundView = nil
		return blockedUsers.count
    }

	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let row = indexPath.row
		let user = blockedUsers[row]
		let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedCell", for: indexPath) as? BlockedCell
		cell?.lblBlockedUser.text = user
		cell?.btnUnblock.tag = row
		cell?.btnUnblock.addTarget(self, action: #selector(UnblockUser(sender:)), for: .touchUpInside)
		return cell!
	}
	
	func Reload(username: String)
	{
		let index = blockedUsers.firstIndex(of: username)
		if index! > -1 && index! < blockedUsers.count
		{
			blockedUsers.remove(at: index!)
		}
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}
	
	@objc func CancelButtonWasTapped(sender: Any)
	{
		self.dismiss(animated: true, completion: nil)
	}
	
	@objc func UnblockUser(sender: Any)
	{
		let button = sender as? UIButton
		let index = button!.tag
		let user = blockedUsers[index]
		let fireDatabaseService = FireDatabaseService()
		fireDatabaseService.unblockUsers(username: user, completion: { [weak self] error in
			Task { @MainActor in
				if error == nil
				{
					self?.Reload(username: user)
				}
			}
		})
		
	}
	//MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
}
