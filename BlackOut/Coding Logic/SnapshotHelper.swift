//
//  SnapshotHelper.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 10/29/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import Foundation
import Firebase

struct SnapToReports
{
    let reports: [IncidentReport]
    
    init?(with snapshot: DataSnapshot)
    {
       var reports = [IncidentReport]()
        guard let snapDict = snapshot.value as? [String: [String:Any]] else {return nil}
        for snap in snapDict
        {
            guard let report = IncidentReport(postId: snap.key, dict: snap.value) else {continue}
           reports.append(report)
        }
        self.reports = reports
    }
}

struct SanpToUserAccount
{
	let currentUser : UserAccount
	init?(with snaphsot: DataSnapshot)
	{
		guard let user  = UserAccount(id: snaphsot.key, dict: snaphsot.value as![String : Any]) else {return nil}
		self.currentUser = user
	}
}

struct SnapToIncidentReport
{
    let report: IncidentReport
    
    init?(with snapshot: DataSnapshot)
    {
        guard let incident = IncidentReport(postId: snapshot.key, dict: snapshot.value as! [String : Any]) else {return nil}
        self.report = incident
        
    }
}
