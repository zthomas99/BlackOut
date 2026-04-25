//
//  DKPickViewController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 12/1/19.
//  Copyright © 2019 FervorWare. All rights reserved.
//

import UIKit
import DKImagePickerController

class DKPickViewController: DKImagePickerController, @unchecked Sendable {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.inline = true
        self.showsCancelButton = false
        self.assetType = .allAssets
		self.showsEmptyAlbums = true
        // Do any additional setup after loading the view.
    }
}
