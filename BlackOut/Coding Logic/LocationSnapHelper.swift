//
//  LocationSnapHelper.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/30/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseCore

struct LocationSnapHelper
{
    let reportLocations: [LocationReport]
    
    init?(with snapshot: QuerySnapshot)
    {
       var reports = [LocationReport]()
       let snapDocs = snapshot.documents
		for snap in snapDocs
		{
			guard let report = LocationReport(postId: snap.documentID, dict: snap.data()) else {continue}
			reports.append(report)
        }
        self.reportLocations = reports
    }
}


struct SnapToUserAccount
{
	let currentUser : UserAccount
	init?(with snaphsot: DocumentSnapshot)
	{
		guard let user  = UserAccount(id: snaphsot.documentID, dict: snaphsot.data()!) else {return nil}
		self.currentUser = user
	}
}
