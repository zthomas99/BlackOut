//
//  AppDelegate.swift
//  BlackOut
//
//  Created by Zacch Thomas on 9/11/18.
//  Copyright © 2018 FervorWare. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
				let notficationHandler = NotificationsHandler(application: application)

        //configureAppearance() // Legacy appearance — Liquid Glass on iOS 26 derives item tint from the background behind the tab bar

        if let placesAPIKey = Bundle.main.object(forInfoDictionaryKey: "GooglePlacesAPIKey") as? String,
           !placesAPIKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            GMSPlacesClient.provideAPIKey(placesAPIKey)
        } else {
            print("Google Places API key missing. Set GooglePlacesAPIKey in Info.plist/build settings.")
        }

				notficationHandler.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func configureAppearance() {
        let gold = UIColor(red: 0.929, green: 0.807, blue: 0.041, alpha: 1)

        // Navigation bar — black background, white title, gold buttons
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = .black
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = gold

        // Tab bar — black background, gold selected, white unselected
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = .black

        tabAppearance.stackedLayoutAppearance.selected.iconColor = gold
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: gold
        ]
        tabAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        UITabBar.appearance().tintColor = gold
        UITabBar.appearance().unselectedItemTintColor = UIColor.white
    }

}
