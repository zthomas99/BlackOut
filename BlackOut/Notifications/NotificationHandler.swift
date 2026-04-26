//
//  NotificationHandler.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 7/1/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
import UIKit
@preconcurrency import Firebase
@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseMessaging
import UserNotifications

class NotificationsHandler: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate
{
	let application: UIApplication
	
	init(application: UIApplication)
	{
		self.application = application
		super.init()
		
		Messaging.messaging().delegate = self
	}
	
	@MainActor
	func registerForRemoteNotifications()
	{
		UNUserNotificationCenter.current().delegate = self
		let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
		UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in})
		application.registerForRemoteNotifications()
	}
	
	func didRegsiterForRemoteNotificatons()
	{
		guard let user = CurrentUserStatus.shared.user else {return}
		
		Messaging.messaging().token {
			token, error
			in
			if let error = error{
				print("Error fetching remote messaging token; \(error)")
			} else if let token = token{
				if !(UserAccount.shared?.fcmTokens.contains(token))!
				{
					FireDatabaseService.shared.updateTokens(userId: user.uid, data: token, completion: {
						(error)
						in
						if let error = error
						{
							print("User \(user.displayName ?? "") failed to update token. Error : \(error)")
						}
						else
						{
							print("registration for user token successful")
						}
					})
				}
			}
		}
	}
	
	func didUnregisterForRemoteNotifications(completion: @escaping () -> Void)
	{
		guard let user = CurrentUserStatus.shared.user else {return}
		
		Messaging.messaging().token {
			token, error
			in
			if let error = error
			{
				print("Error fetching remote messaging token: \(error)")
			}
			else if let token = token {
				FireDatabaseService.shared.removeToken(userId: user.uid, data: token, completion: {
					(error)
					in
					if let error = error
					{
						print("\(String(describing: user.displayName)) failed to remove token due to the following error : \(error)")
					}
					else
					{
						print("Removed token from user")
					}
				})
			}
			completion()
		}
	}
}
