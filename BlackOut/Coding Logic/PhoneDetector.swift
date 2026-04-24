//
//  PhoneDetector.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 10/23/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import Foundation
import UIKit

class PhoneDetector
{
    func DetectDevice()->String
    {
        let height = UIScreen.main.fixedCoordinateSpace.bounds.size.height
        var deviceModel: String
        
        switch(height)
        {
        case 568:
            deviceModel = "iPhone 5s or SE"
            break;
        case 667:
            deviceModel = "iPhone 8/7/6s/6"
            break;
        case 736:
            deviceModel = "iPhone 8/7/6s/6 Plus"
            break;
            
        case 812:
            deviceModel = "iPhone X/Xs"
            break;
        case 896:
            deviceModel = "iPhone XR/X Max"
        default:
            deviceModel = "Dunno. Maybe it's an Android...?"
            break;
        }
        return deviceModel
    }
}
