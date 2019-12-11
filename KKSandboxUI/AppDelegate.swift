//
//  AppDelegate.swift
//  KKSandboxUI
//
//  Created by 王铁山 on 2019/12/11.
//  Copyright © 2019 onety. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController.init(rootViewController: ViewController())
        self.window?.makeKeyAndVisible()
        return true
    }

}

