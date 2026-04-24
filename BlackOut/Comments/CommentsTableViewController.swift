//
//  CommentsTableViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 5/8/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class CommentsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate{

	//MARK: - Fields and Outlets
	var postDate : String?
	var postComment : String?
	var reportTitle : String?
	var postUsername : String?
	var postId : String?
	var popUpUser: String?
	var selectedSection: Int?
	var advices =  [Advice]()
	var commentAdvice : Advice!
	var selectedForReply : Reply!
	var replyMap =  [String : Comment]()
	var offset: CGFloat = 0
	var lockScrollPos : CGFloat?
	var blockedUsers = [String]()
	let commentsViewModel = CommentsViewModel()
	let commentsCoordinator: CommentsCoordinating = CommentsCoordinator.shared
	//Segue Controllers
	var addAdviceTableViewController : AddAdviceTableViewController!
	var addReplyTableViewControler : AddReplyTableViewController!
	var replyReplyTableViewController: AddReplyTableViewController!

	@IBOutlet var popUpView: UIView!
	@IBOutlet weak var popUpCancel: UIButton!
	@IBOutlet weak var lblQuoteUser: UILabel!
	@IBOutlet weak var popUpTextView: UITextView!
	
	@IBOutlet var dimBackView: UIView!
	var cancelButton: UIButton?
	
	//MARK: - Load functions
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.tableFooterView = UIView()
		tableView.estimatedSectionHeaderHeight = 350
		tableView.separatorColor = UIColor.clear
		var frame = CGRect.zero;
		frame.size.height = .leastNormalMagnitude
		tableView.tableHeaderView = UIView(frame: frame)
		
		Reload()
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		lockScrollPos = nil
			commentsViewModel.retrieveBlockedUsers(completion: {
				(users)
				in
				self.blockedUsers = users
				self.Reload()
			})
	}

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
		if(advices.count == 0)
		{
			tableView.backgroundView = nil
			let noDataLabel : UILabel = UILabel(frame: CGRect(x: 0,y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height))
            noDataLabel.text = "No advice or comments"
            noDataLabel.textColor = UIColor.white
            noDataLabel.textAlignment = NSTextAlignment.center
			tableView.backgroundView = noDataLabel
			return 1
		}
		tableView.backgroundView = nil
		return advices.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section > 0
		{
			let index = (section - 1)
			if advices.count > 0
			{
				if advices[index].isExpanded == false
				{
					return 0
				}
				return advices[index].replies?.count ?? 0
			}
		}
		//return
		return 0
    }

     override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if section == 0
		{
			let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell
			cell?.addAdviceBtn.addTarget(self, action: #selector(AddAdviceTapped), for: .touchUpInside)
			cell?.lblReportTitle.text = reportTitle?.uppercased()
			cell?.lblDate.text = postDate
			cell?.lbllUsername.text = postUsername
			cell?.reportTextView.text = postComment
			cell?.reportTextView.layer.borderColor = UIColor.white.cgColor
			cell?.reportTextView.layer.borderWidth	= 0.5
			cell?.reportTextView.layer.cornerRadius = (cell?.reportTextView.frame.height)!/30
			return cell?.contentView
		}
		else
		{
			let index = (section - 1)
			let adviceCell = tableView.dequeueReusableCell(withIdentifier: "AdviceCell") as? AdviceCell
			
			//set tags
			adviceCell?.upVoteBtn.tag = section
			adviceCell?.downVoteBtn.tag = section
			adviceCell?.addCommentBtn.tag = section
			adviceCell?.viewRepliesBtn.tag = section
			adviceCell?.btnUsernameOverlay.accessibilityIdentifier = advices[index ].user
			
			//add targets for buttons
			adviceCell?.upVoteBtn.addTarget(self, action: #selector(UpVoteBtnTapped(sender:)), for: .touchUpInside)
			
			adviceCell?.downVoteBtn.addTarget(self, action: #selector(DownBtnTapped(sender:)), for: .touchUpInside)
			
			adviceCell?.addCommentBtn.addTarget(self, action: #selector(AddComentTapped(sender:)), for: .touchUpInside)
			
			adviceCell?.viewRepliesBtn.addTarget(self, action: #selector(ExpandCloseReplies(sender:)), for: .touchUpInside)
			
			adviceCell?.btnUsernameOverlay.addTarget(self, action: #selector(ShowUserOptions(sender:)), for: .touchUpInside)
			// add label info and text view comment
			adviceCell?.lblUsername.text = advices[index ].user
			adviceCell?.lblAdviceComment.text = advices[index].comment
			adviceCell?.viewRepliesBtn.setTitle(advices[index].isExpanded ? "Close Replies" : (advices[index].commentCount > 0 ? "View " + String(describing: advices[index].commentCount ) + " Replies" : String(describing: advices[index].commentCount ) + " Replies"), for: .normal)
	
			//design cell border.

			let voteCount = advices[index].upVoters!.count - advices[index].downVoters!.count
			
			let dateFormatter = DateFormatter()
			dateFormatter.dateStyle = .medium
			dateFormatter.timeZone = .none
			dateFormatter.locale = Locale(identifier: "en_US")

			adviceCell?.navigatonView.dropShadow(color: UIColor.black)
			
			let calendar = Calendar.current
			if calendar.isDate(advices[index].date, inSameDayAs: Date())
			{
				adviceCell?.lblDate.text = Date().timeAgo(compare: advices[index].date)
			}
			else
			{
				adviceCell?.lblDate.text = dateFormatter.string(from: advices[index].date)
			}
			
			adviceCell?.lblVoteCount.text = String(describing: voteCount)
			adviceCell?.advice = advices[index]
			
			return adviceCell?.contentView
		}
	}
    
	override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		return 1
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let section = (indexPath.section - 1)
		let row = indexPath.row
		let reply : Reply = (advices[section].replies?[row])!
		
		if !reply.hasReply
		{
			let cell = (tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath) as? ReplyCell)!
			// Configure the cell...
			cell.SetUpCell(cellReply: reply, commentTableViewController: self, forIndex: IndexPath(row: row, section: section) )
			cell.StyleCell()
			
			cell.tag = row
			cell.accessibilityIdentifier = "\(section)"
			cell.btnUsernameOverlay.accessibilityIdentifier = reply.user
			cell.btnUsernameOverlay.addTarget(self, action: #selector(ShowUserOptions(sender:)), for: .touchUpInside)
			if row != 0
			{
				let frame  = CGRect(x: 0, y: 0, width: (self.view.frame.width), height: 0.5)
			let borderline = UIView(frame: frame)
			borderline.backgroundColor = UIColor.white
			cell.contentView.addSubview(borderline)
			}
			
			if replyMap[reply.id] == nil
			{
				let comment = Comment(comment: reply.comment, user: reply.user)
				replyMap[reply.id] = comment
			}
			return cell
		}
		
		let subReply = tableView.dequeueReusableCell(withIdentifier: "SubReplyCell") as! SubReplyCell
		subReply.initializeSubCell(subReply: reply, commentTableViewController: self, forIndex: IndexPath(row: row, section: section))
		
		let frame  = CGRect(x: 0, y: 0, width: (self.view.frame.width), height: 0.5)
		let borderline = UIView(frame: frame)
		borderline.backgroundColor = UIColor.white
		subReply.contentView.addSubview(borderline)
		subReply.tag = row
		subReply.accessibilityIdentifier = "\(section)"
		
		if replyMap[reply.id] == nil
		{
			let comment = Comment(comment: reply.comment, user: reply.user)
			replyMap[reply.id] = comment
		}
		subReply.btnUsernameOverlay.accessibilityIdentifier = reply.user
		subReply.btnUsernameOverlay.addTarget(self, action: #selector(ShowUserOptions(sender:)), for: .touchUpInside)
		subReply.btnShowSourceComment.tag = row
		subReply.btnShowSourceComment.accessibilityIdentifier = "\(section)"
		subReply.btnShowSourceComment.addTarget(self, action: #selector(ShowSourceComment(sender:)), for: .touchUpInside)
		return subReply
	}
	
       
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
	return  800
	}


	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
	}
	
	//MARK: - Segue function
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if(segue.identifier == "ShowAddAdvice")
		{
			addAdviceTableViewController = segue.destination as? AddAdviceTableViewController
			addAdviceTableViewController.reportTitle = reportTitle
			addAdviceTableViewController.postId = postId
			addAdviceTableViewController.instanceOfCommentTableViewController = self
		}
		else if (segue.identifier == "ShowAddReply")
		{
			addReplyTableViewControler	= segue.destination as? AddReplyTableViewController
			addReplyTableViewControler.postId = postId
			addReplyTableViewControler.advice = commentAdvice
			addReplyTableViewControler.isReplyToAdvice = true
			addReplyTableViewControler.tag = selectedSection
			addReplyTableViewControler.instanceOfCommentTableViewController	= self
		}
		else if (segue.identifier == "ShowReplyReply")
		{
			replyReplyTableViewController = segue.destination as? AddReplyTableViewController
			replyReplyTableViewController!.reply = selectedForReply
			replyReplyTableViewController!.postId = postId
			replyReplyTableViewController!.advice = commentAdvice
			replyReplyTableViewController!.isReplyToAdvice = false
			replyReplyTableViewController!.instanceOfCommentTableViewController = self
			replyReplyTableViewController!.tag = selectedSection
		}
		else if (segue.identifier == "ShowUserReports")
		{
			let userViewContller = segue.destination as? UserProfileReportTableViewController
			userViewContller?.username = popUpUser
		}
		
	}
	
	@objc func ResizeTableCells(indexPath: IndexPath)
	{
		UIView.animate(withDuration: 0.5, animations: {
			self.tableView.beginUpdates()
			self.tableView.endUpdates()
			self.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
		})
	}

	//MARK: - UIAction Button functions
	
	func ShowAddReply(sender: Any)
	{
		lockScrollPos = tableView.contentOffset.y
		let indexPath = sender as? IndexPath
		let reply = advices[indexPath!.section].replies![indexPath!.row]
		
		selectedSection = indexPath?.section
		selectedForReply = reply
		commentAdvice = advices[indexPath!.section]
		commentsCoordinator.showReplyReply(from: self)
	}
	
	
	@objc func UpVoteBtnTapped(sender: UIButton)
	{
		lockScrollPos = tableView.contentOffset.y
		let section = sender.tag
		let index = (section - 1)
		guard let userId = commentsViewModel.currentUserId() else { return }
		commentsViewModel.applyUpVote(to: &advices[index], userId: userId)
		commentsViewModel.setVoters(postId: postId!, advice: advices[index], completion: {
			(error)
			in
			if error == nil
			{
				self.ReloadByIndex(index: index)
			}
		})
		
	}
	
	@objc func ShowSourceComment(sender: Any)
	{
		//Get Location info of the subReply
		tableView.isScrollEnabled = false
		let button = sender as? UIButton
		let row = button!.tag
		let section = Int((button?.accessibilityIdentifier)!)
		let indexPath = IndexPath(row: row, section: section!)
		
		//Retrieve subReply and get source ID
		let subReply = advices[indexPath.section].replies![indexPath.row]
		let sourceId = (subReply.quoteId)
		
		//Check to see if sourc cell is mapped
		//If so retrieve content view and perform segue
		if replyMap[sourceId] != nil
		{
			let totalHeight = tableView.contentSize.height + offset
			dimBackView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: totalHeight)
			animateIn(desiredView: dimBackView, alpha: 0.7)
			
			popUpTextView.text = replyMap[sourceId]?.comment
			let username = replyMap[sourceId]!.user
			lblQuoteUser.text = "@\(username ?? "unknown")"
			print("Comment character count : \(String(describing: replyMap[sourceId]?.comment.count))")
			let popHeight = resizeSubViews(viewer: popUpView)
			var newFrame : CGRect
			
			if popHeight > self.view.frame.height
			{
				newFrame = CGRect(x: popUpView.bounds.origin.x, y: popUpView.bounds.origin.y, width: popUpView.frame.width, height: self.view.frame.height * 0.9)
				popUpTextView.isScrollEnabled = true
			}
			else
			{
			newFrame = CGRect(x: popUpView.bounds.origin.x, y: popUpView.bounds.origin.y, width: popUpView.frame.width, height: popHeight)
			}
			popUpView.layer.borderColor = UIColor.white.cgColor
			popUpView.layer.borderWidth = 1.0
			popUpView.frame = newFrame
			animateIn(desiredView: popUpView, alpha: 1.0)
	
		}
	}
	
	@objc func ShowUserOptions(sender: Any)
	{
		let button = sender as? UIButton
		popUpUser = button?.accessibilityIdentifier
		
		let userOptionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		
			let userReportAction = UIAlertAction(title: "Show \(String(describing: popUpUser ?? "unknown"))'s Reports", style: .default, handler: {(action: UIAlertAction!) -> Void
				in
				self.commentsCoordinator.showUserReports(from: self)
			})
		
		userOptionSheet.addAction(userReportAction)
		
		if popUpUser != Auth.auth().currentUser?.displayName
		{
			let blockUserAction = UIAlertAction(title: "Block \(String(describing: popUpUser ?? "unknown"))", style: .default, handler: {(action: UIAlertAction!) -> Void
				in
					self.blockedUsers.append(self.popUpUser!)
					self.commentsViewModel.addBlockedUser(username: self.popUpUser!, completion: {
						(error)
						in
						if error == nil
						{
							self.Reload()
						}
					})
				})
			
			userOptionSheet.addAction(blockUserAction)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) -> Void
			in
			userOptionSheet.dismiss(animated: true, completion: nil)
		})
		
		userOptionSheet.addAction(cancelAction)
		
		if let userOptionSheet = userOptionSheet.popoverPresentationController {
			userOptionSheet.sourceView = sender as! UIButton
			userOptionSheet.sourceRect = CGRect(x: (button?.bounds.midX)!, y: ((button?.bounds.minY)! + 5), width: 0, height: 0)
			userOptionSheet.permittedArrowDirections = .down
		}
		
		self.present(userOptionSheet,animated: true, completion: nil)
	}
	
	func animateIn(desiredView: UIView, alpha: CGFloat)
	{
		let backgroundView = self.view!
		let totalHeight = self.view.center.y + offset
		let centerPoint = CGPoint(x: tableView.contentSize.width/2, y: totalHeight)
		
		backgroundView.addSubview(desiredView)
		
		desiredView.transform = CGAffineTransform(scaleX: 1.2 , y: 1.2)
		desiredView.alpha = 0
		desiredView.center = centerPoint
		UIView.animate(withDuration: 0.3, animations:
		{
			desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
			desiredView.alpha = alpha
		})
	}
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		if lockScrollPos != nil
		{
			tableView.setContentOffset(CGPoint(x: 0,y: lockScrollPos!), animated: false)
		}
		offset = scrollView.contentOffset.y
	}
	
	func animateOut(desiredView: UIView)
	{
		UIView.animate(withDuration: 0.3, animations:
		{
			desiredView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
			desiredView.alpha = 0
		}, completion: { _ in
			desiredView.removeFromSuperview()
			desiredView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
		})
	}
	
	func resizeSubViews(viewer: UIView) -> CGFloat
	{
		var contentHeight : CGFloat = 0.0
		viewer.subviews.forEach{
			(view)
			
			in
			
			let heightSize = CGSize(width: view.frame.width, height: .infinity)
			let estimatedHeightSize = view.sizeThatFits(heightSize)
			
			let newFrame = CGRect(x: view.bounds.origin.x, y: view.bounds.origin.y, width: view.frame.width, height: estimatedHeightSize.height)
			view.frame = newFrame
			contentHeight += estimatedHeightSize.height
		}
		return contentHeight
	}
	
	@IBAction func PopUpCancelTapped(_ sender: Any) {
		animateOut(desiredView: dimBackView)
		animateOut(desiredView: popUpView)
		self.tableView.isScrollEnabled = true
	}
	
	
	@IBAction func BackButtonTapped(_ sender: Any) {
		commentsCoordinator.dismiss(from: self)
	}
	
	@objc func AddAdviceTapped()
	{
		commentsCoordinator.showAddAdvice(from: self)
	}
	
	@objc func AddComentTapped(sender : UIButton)
	{
		let section = sender.tag
		let index = (section - 1)
		selectedSection = index
		commentAdvice = advices[index]
		commentsCoordinator.showAddReply(from: self)
	}
	
	@objc func ExpandCloseReplies(sender: UIButton)
	{
		let section = sender.tag
		let index = (section - 1)
		var indexPaths = [IndexPath]()
		var indexSets =  IndexSet()
		
		if advices[index].replies == nil
		{
			return
		}
		
		for row in advices[index].replies!.indices
		{
			let indexPath = IndexPath(row: row, section: section)
			indexPaths.append(indexPath)
			indexSets.insert(section)
		}
		
		let isExpanded = advices[index].isExpanded
		advices[index].isExpanded = !isExpanded
		
		tableView.beginUpdates()
		if advices[index].isExpanded
		{
			tableView.insertRows(at: indexPaths, with: .top)
			
		}
		else
		{
			tableView.deleteRows(at: indexPaths, with: .fade)
		}
		tableView.endUpdates()
		
		tableView.reloadSections(indexSets, with: .none)
		if advices[index].isExpanded && indexPaths.count > 0
		{
			tableView.scrollToRow(at: indexPaths[0], at: .middle, animated: true)
		}
		else
		{
			tableView.beginUpdates()
			tableView.endUpdates()
		}
		
	}
	
  
	@objc func DownBtnTapped(sender : UIButton)
	{
		lockScrollPos = tableView.contentOffset.y
		let section = sender.tag
		let index = (section - 1)
		guard let userId = commentsViewModel.currentUserId() else { return }
		commentsViewModel.applyDownVote(to: &advices[index], userId: userId)
		commentsViewModel.setVoters(postId: postId!, advice: advices[index], completion: {
			(error)
			in
			if error == nil
			{
				self.ReloadByIndex(index: index)
			}
		})
		
	}
	
	//MARK: - Set Battery and Time to White
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
	
	@objc func Reload()
	{
		guard let postId = postId else { return }
		commentsViewModel.retrieveAdvices(postId: postId, blockedUsers: blockedUsers, completion: {
			(advices)
			in
			self.advices = advices
			DispatchQueue.main.async {
				self.tableView.reloadData(completion: {
					self.lockScrollPos = nil
				})
			}
		})
	}
	
	@objc func ReloadByIndex(index: Int)
	{
		guard let postId = postId else { return }
		if index < 0 || index >= advices.count { return }

		commentsViewModel.retrieveAdvice(postId: postId, adviceId: advices[index].id, blockedUsers: blockedUsers, completion: {
			(advice)
			in
			if advice != nil
			{
				self.advices[index] = advice!
			}
			DispatchQueue.main.async {
				self.tableView.reloadData(completion: {
					self.lockScrollPos = nil
				})
			}
		})
	}
}
extension UITableView {
    func reloadData(completion: @escaping ()->()) {
		UIView.animate(withDuration: 0, animations: { self.reloadData() })
            { _ in completion() }
    }
}
