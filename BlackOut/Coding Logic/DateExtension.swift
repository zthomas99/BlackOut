//
//  DateExtension.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 6/30/20.
//  Copyright © 2020 FervorWare. All rights reserved.
//

import Foundation
extension Date{
	
	func timeAgo(compare date: Date) -> String
	{
		if #available(iOS 13.0, *) {
			let formatter = RelativeDateTimeFormatter()
			formatter.unitsStyle = .full
			let agoString = formatter.localizedString(for: date, relativeTo: Date())
			return agoString
		} else {
			let calendar = Calendar.current
			guard let minuteAgo = calendar.date(byAdding: .minute, value: -1, to: Date()),
				  let hourAgo = calendar.date(byAdding: .hour, value: -1, to: Date()) else {
				return ""
			}
			
			if minuteAgo < self
			{
				let diff = Calendar.current.dateComponents([.second], from: self, to: Date()).second ?? 0
				return "\(diff) seconds ago"
			}
			else if hourAgo < self
			{
				let diff = Calendar.current.dateComponents([.minute], from: self, to: Date()).minute ?? 0
				return "\(diff) minutes ago"
			}
			else
			{
				let diff = Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
				return "\(diff) hours ago"
			}
		
		}
		
	}
}
