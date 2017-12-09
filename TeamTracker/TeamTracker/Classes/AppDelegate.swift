//
//  AppDelegate.swift
//  SampleChatApp
//
//  Created by Shaik on 10/10/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

import UIKit
import FBSDKCoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
    var window: UIWindow?
    var statusBarBackgroundView: UIView?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        window?.rootViewController = UINavigationController(rootViewController: LoginController())
        UINavigationBar.appearance().barTintColor = UIColor.init(r: 10, g: 82, b: 8)

        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]

        UIApplication.shared.statusBarStyle = .lightContent
        
        statusBarBackgroundView = UIView()
        statusBarBackgroundView?.backgroundColor = UIColor.init(r: 2, g: 82, b: 8)
        
        statusBarBackgroundView?.translatesAutoresizingMaskIntoConstraints = false
        
        window?.addSubview(statusBarBackgroundView!)
        if UIDevice.current.modelName == "Simulator" || UIDevice.current.modelName == "iPhone X" {
           // print("iPhone X")
            window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":statusBarBackgroundView]))
            window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(34)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":statusBarBackgroundView]))
        }else{
           // print("Not iPhone X")
            window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":statusBarBackgroundView]))
            window?.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0(20)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":statusBarBackgroundView]))
        }
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
      let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        return handled;
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketIOManager.sharedInstance.closeConnection()
        print("Connection Closed")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        SocketIOManager.sharedInstance.establishConnection()
        print("Connection Established")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

