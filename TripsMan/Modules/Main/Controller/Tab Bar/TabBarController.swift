//
//  TabBarController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 29/12/22.
//

import UIKit
import SideMenu

struct CountrySelection: Codable {
    var name: String
    var icon: String
    var countryCode: String
    var currency: String
    var id: Int
}

struct LanguageSelection {
    var name: String
    var id: Int
}

class TabBarController: UITabBarController, TabBarActionDelegate {
    
    
    @IBOutlet weak var countryBtn: UIBarButtonItem!
    var countries = [CountrySelection]()
    var languages = [LanguageSelection]()
    
    var selectedCountry: CountrySelection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarDelegate = self
        
        countries = [CountrySelection(name: "India", icon: "country-india", countryCode: "IND", currency: "INR", id: 1),
                     CountrySelection(name: "UAE", icon: "country-uae", countryCode: "UAE", currency: "AED", id: 2)]
        languages = [LanguageSelection(name: "English", id: 1)]
        
        selectedCountry = countries[0]
        addRightBarItems()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
            
    func addRightBarItems() {
        
        //Country Button
        let countryImage = selectedCountry?.icon ?? "country-india"
        let countryButton = UIButton(type: .custom)
        countryButton.setImage(UIImage(named: countryImage), for: .normal)
        countryButton.imageView?.contentMode = .scaleAspectFit
        let items = countries.map { UIAction(title: "\($0.name)",image: UIImage(named: "\($0.icon)"), handler: countryHandler) }
        countryButton.menu = UIMenu(children: items)
        countryButton.showsMenuAsPrimaryAction = true
        countryButton.frame = CGRectMake(0, 0, 30, 30)
        let countryBarButton = UIBarButtonItem(customView: countryButton)
        
        //Language Button
        let languageImage = "language"
        let languageButton = UIButton(type: .custom)
        languageButton.setImage(UIImage(named: languageImage), for: .normal)
        let languageItems = languages.map { UIAction(title: "\($0.name)", handler: languageHandler) }
        languageButton.menu = UIMenu(children: languageItems)
        languageButton.showsMenuAsPrimaryAction = true
        languageButton.frame = CGRectMake(0, 0, 30, 30)
        let langBarButton = UIBarButtonItem(customView: languageButton)
        
        //Notification
        let notifImage = "icon-nav-notification"
        let notifButton = UIButton(type: .custom)
        notifButton.setImage(UIImage(named: notifImage), for: .normal)
        notifButton.addTarget(self, action: #selector(notificationTapped), for: .touchUpInside)
        notifButton.frame = CGRectMake(0, 0, 30, 30)
        let notifBarButton = UIBarButtonItem(customView: notifButton)
        
        self.navigationItem.rightBarButtonItems = [notifBarButton, langBarButton, countryBarButton]
    }
    
    
    func menuButtonTapped() {
        let vc = UIStoryboard(name: "SideMenu", bundle: nil).instantiateViewController(withIdentifier: "SideMenu") as! SideMenuTableViewController
        let menu = SideMenuNavigationController(rootViewController: vc)
        menu.presentationStyle = .menuSlideIn
        menu.leftSide = true
        present(menu, animated: true)
    }
    
    @objc func notificationTapped() {
        if SessionManager.shared.getLoginDetails() != nil {
            performSegue(withIdentifier: "toNotification", sender: nil)
        } else {
            performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
    
    func presentVC(_ identifier: String) {
        performSegue(withIdentifier: identifier, sender: nil)
    }
    
    func switchTab(_ index: Int) {
        DispatchQueue.main.async {
            self.selectedIndex = index
            
        }
        self.dismiss(animated: true)
    }
    
    func countryHandler(action: UIAction) {
        if selectedCountry?.name != action.title {
            self.view.makeToast("Country changed to \(action.title)")
        }
        selectedCountry = countries.filter { $0.name == action.title }.last
        if selectedCountry != nil {
            SessionManager.shared.setCountry(selectedCountry!)
            addRightBarItems()
        }
    }
    
    func languageHandler(action: UIAction) {
        //TODO: -
//        if selectedCountry?.name != action.title {
//            self.view.makeToast("Country changed to \(action.title)")
//        }
    }
}


protocol TabBarActionDelegate {
    func menuButtonTapped()
    func presentVC(_ identifier: String)
    func switchTab(_ index: Int)
}
