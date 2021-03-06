//
//  SceneDelegate.swift
//  CoronaCases
//
//  Created by SwiftiSwift on 20.03.20.
//  Copyright © 2020 SwiftiSwift. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        changeUIStyleToSettings()
        checkForUpdate(showPopupWhenUpToDate: false)
    }
    
    func changeUIStyle(to style: UIUserInterfaceStyle) {
        self.window?.overrideUserInterfaceStyle = style
    }
    
    func changeUIStyleToSettings() {
        let userDefaults = UDService.instance

        if !userDefaults.setDarkMode {
            userDefaults.useDeviceUIStyleSwitch = true
            userDefaults.darkModeSwitch = window?.traitCollection.userInterfaceStyle == .dark ? true : false
        } else {
            changeUIStyle(to: userDefaults.useDeviceUIStyleSwitch ? .unspecified :
                (userDefaults.darkModeSwitch ? .dark : .light)
            )
        }
    }
    
    func checkForUpdate(showPopupWhenUpToDate: Bool) {
        guard let tabBarController = window?.rootViewController as? UITabBarController else { return }
        
        APIService.instance.checkForUpdate { [weak self] (result) in
            print("Checking for update")
            DispatchQueue.main.async {
                guard let self = self else { return }

                switch result {
                case .success(let updateInfo):
                    let hasUpdate = updateInfo.updateAvailable
                    updateIsAvailable = hasUpdate

                    NotificationCenter.default.post(name: NSNotification.Name.SUCCESS_SEARCHING_FOR_UPDATE, object: nil)

                    if (hasUpdate || showPopupWhenUpToDate){
                        Alert.showUpdate(changelog: updateInfo.changelog, hasUpdate: hasUpdate, onVC: tabBarController)
                    }
                    guard hasUpdate else { return }
                    NotificationCenter.default.post(name: NSNotification.Name.NEW_UPDATE, object: hasUpdate)
                    tabBarController.viewControllers?.last?.tabBarItem.badgeValue = "1"

                case .failure(let error):
                    NotificationCenter.default.post(name: NSNotification.Name.ERROR_SEARCHING_UPDATE, object: nil)
                    Alert.showReload(
                        forError: error,
                        title: loc(.errorSearchingForUpdate),
                        onVC: tabBarController.mostTopVC,
                        reloadTapped: {
                            NotificationCenter.default.post(name: NSNotification.Name.ERROR_SEARCHING_UPDATE_RELOAD_TAPPED, object: nil)
                            self.checkForUpdate(showPopupWhenUpToDate: showPopupWhenUpToDate)
                        })
                }
            }
        }
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
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

