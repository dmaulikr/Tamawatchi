//
//  AppDelegate.swift
//  Tamawatchi
//
//  Created by Morgan Steffy on 3/15/16.
//  Copyright © 2016 Morgan Steffy. All rights reserved.
//

import UIKit
import PushKit
import FBSDKCoreKit
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Pushbots.sharedInstanceWithAppId("56e86de537d9b058018b4569");
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }
    

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let handled: Bool = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        // Add any custom logic here.
        return handled
    }
  
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    // MARK: Push notifications
    
    func application(application: UIApplication,
        didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
            
            //start earthquake, if recieved earthquake notification
            if let msgType = userInfo["msgType"] as? String {
                if(msgType == "earthquake"){
                    NSNotificationCenter.defaultCenter().postNotificationName("startEarthquake", object: nil)
                }
            }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // This method will be called everytime you open the app
        
        // Register the deviceToken on Pushbots
        Pushbots.sharedInstance().registerOnPushbots(deviceToken);
        
        NSUserDefaults.standardUserDefaults().setObject(deviceToken.hexString, forKey: "pushToken")

    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Notification Registration Error.");
    }
    
    func receivedPush(userInfo: [NSObject: AnyObject]?) {
        
        var pushNotification: AnyObject?;
        
        if let remoteNotificationPayload = userInfo?["aps"] as? NSDictionary {
            pushNotification = remoteNotificationPayload;
        }
        
        //Try to get Notification from [didReceiveRemoteNotification] dictionary
        if let remoteNotificationPayload = userInfo?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            pushNotification = remoteNotificationPayload["aps"];
        }
        
        if pushNotification == nil {
            return;
        }
    }
}

//to convert deviceToken to string to save in Firebase
extension NSData {
    var hexString: String {
        let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer(self.bytes), count:self.length)
        return bytes.map { String(format: "%02hhx", $0) }.reduce("", combine: { $0 + $1 })
    }
}