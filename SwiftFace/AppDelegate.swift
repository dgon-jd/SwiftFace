//
//  AppDelegate.swift
//  SwiftFace
//
//  Created by Dmitry Goncharenko on 8/20/14.
//  Copyright (c) 2014 Dmitry Goncharenko. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


 func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        CoreDataManager.sharedInstance.saveContexts()
    }
}

