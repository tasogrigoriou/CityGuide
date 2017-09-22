//
//  AppDelegate.swift
//  CityGuide
//
//  Created by Anastasios Grigoriou on 9/20/17.
//  Copyright © 2017 Grigoriou. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    UINavigationBar.appearance().tintColor = UIColor.blue
    UINavigationBar.appearance().barTintColor = UIColor.blue
    
    // Enable storing and querying data from Local Datastore.
    Parse.enableLocalDatastore()
    
    let parseConfiguration = ParseClientConfiguration { (ParseMutableClientConfiguration) in
      
      ParseMutableClientConfiguration.applicationId = "6a79abafe9e7a3b99131df32c6191ca92edcae01"
      ParseMutableClientConfiguration.clientKey = "082e5bd231fdd84d5c0fa78e7334f8cc10dbeeee"
      ParseMutableClientConfiguration.server = "http://52.14.145.65:80/parse"
    }
    Parse.initialize(with: parseConfiguration)
    
    let defaultACL = PFACL()
    defaultACL.getPublicReadAccess = true
    defaultACL.getPublicWriteAccess = true
    PFACL.setDefault(defaultACL, withAccessForCurrentUser: true)
    
    rememberLogin()
    
    return true
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
  
  func rememberLogin() {
    let user : String? = UserDefaults.standard.string(forKey: "userloggedin")
    
    if user != nil {
      let board : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
      
      let navigationController = board.instantiateViewController(withIdentifier: "navigationVC") as! UINavigationController
      
      window?.rootViewController = navigationController
    }
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let installation = PFInstallation.current()
    installation?.setDeviceTokenFrom(deviceToken)
    installation?.saveInBackground()

    PFPush.subscribeToChannel(inBackground: "") { (succeeded, error) in
      if succeeded {
        print("Successfully subscribed to push notifications on the broadcast channel.\n");
      } else {
        print(error?.localizedDescription as Any)
      }
    }
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(error.localizedDescription)
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    PFPush.handle(userInfo)
    if application.applicationState == UIApplicationState.inactive {
      PFAnalytics.trackAppOpened(withRemoteNotificationPayload: userInfo)
    }
  }
  
}



