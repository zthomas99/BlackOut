//
//  MainTabBarController.swift
//  BlackOut
//
//  Created by Zacchaeus Thomas on 4/21/26.
//  Copyright © 2026 FervorWare. All rights reserved.
//

import Foundation

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let gold = UIColor(red: 0.929, green: 0.807, blue: 0.041, alpha: 1)

        tabBar.items?.forEach { item in
            item.image = item.image?.withRenderingMode(.alwaysTemplate)
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysTemplate)
        }

        tabBar.tintColor = gold

        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior = .never
        }
    }

    // Disable the default tab bar item bounce animation
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Intentionally empty — overriding prevents the default spring animation
    }
}
