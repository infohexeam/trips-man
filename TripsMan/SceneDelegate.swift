//
//  SceneDelegate.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 05/09/22.
//

import UIKit
import FirebaseDynamicLinks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomigURL = userActivity.webpageURL{
            print("Incoming URL is \(incomigURL)")
            _ = DynamicLinks.dynamicLinks().handleUniversalLink(incomigURL) { (dynamiclink, error) in
                if let dynamiclink = dynamiclink, let _ = dynamiclink.url {
                    self.handleIncomingDynamicLink(dynamiclink)
                } else {
                    print("dynamiclink = nil")
                }
            }
            return
        }
        print("userActivity = nil")
//        return false
    }
    
    func handleIncomingDynamicLink(_ dynamicLink: DynamicLink) {
        guard let url = dynamicLink.url else {
            print("That's weird. My dynamic link obiect has no url")
            return
        }
        print("dynamic link url: \(url)")
        
        if url.lastPathComponent == "resetPassword" {
            if let token = getQueryStringParameter(url: url.absoluteString, param: "token") {
                if let email = getQueryStringParameter(url: url.absoluteString, param: "email") {
                    print("email is \(email) & token is \(token)")
                    navigateToResetPassword(token, email: email)
                }
            }
        }
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
}

extension SceneDelegate {
    func navigateToResetPassword(_ token: String, email: String) {
        
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .automatic
        navController.isNavigationBarHidden = false
        navController.navigationBar.tintColor = .black
        window.rootViewController = navController
        
        window.makeKeyAndVisible()
        let resetVC = UIStoryboard(name: "LoginModule", bundle: nil).instantiateViewController(identifier: "resetPassword") as! ResetPasswordViewController
        resetVC.token = token
        resetVC.email = email
        navController.present(resetVC, animated: true)
    }
    
    
}


