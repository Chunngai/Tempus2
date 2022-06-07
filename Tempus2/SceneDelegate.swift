//
//  SceneDelegate.swift
//  Tempus2
//
//  Created by Sola on 2021/8/30.
//  Copyright © 2021 Sola. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
                
        self.window = UIWindow(windowScene: scene as! UIWindowScene)
        
        let calendarViewController = CalendarViewController()
        calendarViewController.updateValues(date: Date())
        let navController = NavController(rootViewController: calendarViewController)
        
        self.window?.rootViewController = navController
        self.window?.makeKeyAndVisible()
        
        let homeViewController = HomeViewController()
        homeViewController.viewDidLayoutSubviews()
        homeViewController.updateValues(tasks: calendarViewController.tasks, date: Date(), delegate: calendarViewController)
        navController.pushViewController(homeViewController, animated: false)
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("sceneWillEnterForeground")
        // Stops the running alarms (if any).
        removeAllNotifications()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("sceneDidEnterBackground")
        // Recovers the stopped alarms (if any).
        prepareForNotifications(alarmNotificationType: .hidden)
    }


}

