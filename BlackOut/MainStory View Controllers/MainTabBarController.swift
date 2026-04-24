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
        let unselectedGray = UIColor(white: 0.55, alpha: 1)

        // Make sure the images can actually be tinted
        tabBar.items?.forEach { item in
            item.image = item.image?.withRenderingMode(.alwaysTemplate)
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysTemplate)
        }

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()

        // Keep your black background
        appearance.backgroundColor = .black

        // Selected
        appearance.stackedLayoutAppearance.selected.iconColor = gold
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: gold
        ]

        // Unselected
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        // Also set this directly as a fallback
        tabBar.tintColor = gold
        tabBar.unselectedItemTintColor = UIColor.white

        // Prevent the tab bar from minimizing/expanding on selection
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior = .never
        }
    }

    // Disable the default tab bar item bounce animation
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // Intentionally empty — overriding prevents the default spring animation
    }
}
