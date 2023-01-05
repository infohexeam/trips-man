//
//  TabBarController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 29/12/22.
//

import UIKit
import SideMenu

class TabBarController: UITabBarController, TabBarActionDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tabBarDelegate = self
    }
    
    
    func menuButtonTapped() {
        let vc = UIStoryboard(name: "SideMenu", bundle: nil).instantiateViewController(withIdentifier: "SideMenu") as! SideMenuTableViewController
        let menu = SideMenuNavigationController(rootViewController: vc)
        menu.presentationStyle = .menuSlideIn
        menu.leftSide = true
        present(menu, animated: true)
    }
    
    func presentVC(_ identifier: String) {
        performSegue(withIdentifier: identifier, sender: nil)
    }
    
    func switchTab(_ index: Int) {
        self.selectedIndex = index
        dismiss(animated: true)
    }

}


protocol TabBarActionDelegate {
    func menuButtonTapped()
    func presentVC(_ identifier: String)
    func switchTab(_ index: Int)
}
