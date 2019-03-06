//
//  AppDelegate.swift
//  SwiftAudio
//
//  Created by Jørgen Henrichsen on 03/11/2018.
//  Copyright (c) 2018 Jørgen Henrichsen. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        application.beginReceivingRemoteControlEvents()
        FirebaseApp.configure()
        TimeTracker.shared.getAllRecordsDuration { (newsTitle, duration) in
            if let duration = duration {
                let params: [String : Any] = [
                    "title": newsTitle,
                    "value": duration
                    ]
                Analytics.logEvent("listen_audio",parameters: params)
            }
        }
        TimeTracker.shared.removeTimerRecords()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        TimeTracker.shared.getAllRecordsDuration() { audioName, duration in
            print("\(audioName): ", duration ?? "none")
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        TimeTracker.shared.recordPauseBeforeTermination()
    }


}

