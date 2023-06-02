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
    
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var countryImage: UIImageView!
    
    @IBOutlet weak var languageButton: UIButton!
    
    var countries = [CountrySelection]()
    var languages = [LanguageSelection]()
    
    var selectedCountry: CountrySelection? {
        didSet {
            if let selectedCountry = selectedCountry {
                countryImage.image = UIImage(named: selectedCountry.icon)
                SessionManager.shared.setCountry(selectedCountry)
            }
        }
    }   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarDelegate = self
        
        countries = [CountrySelection(name: "India", icon: "country-icon", countryCode: "IND", currency: "INR", id: 1),
                     CountrySelection(name: "UAE", icon: "uae", countryCode: "UAE", currency: "AED", id: 2)]
        languages = [LanguageSelection(name: "English", id: 1)]
        
        selectedCountry = countries[0]
        setupMenu()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    func setupMenu() {
        //Country
        let items = countries.map { UIAction(title: "\($0.name)",image: UIImage(named: "\($0.icon)"), handler: countryHandler) }
        countryButton.menu = UIMenu(title: "", children: items)
        countryButton.showsMenuAsPrimaryAction = true
        
        //Language
        let languageItems = languages.map { UIAction(title: "\($0.name)", handler: languageHandler) }
        languageButton.menu = UIMenu(title: "", children: languageItems)
        languageButton.showsMenuAsPrimaryAction = true
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
    }
    
    func languageHandler(action: UIAction) {
        //TODO: -
//        if selectedCountry?.name != action.title {
//            self.view.makeToast("Country changed to \(action.title)")
//        }
    }
    
    @IBAction func notificationTapped(_ sender: UIButton) {
        if SessionManager.shared.getLoginDetails() != nil {
            performSegue(withIdentifier: "toNotification", sender: nil)
        } else {
            performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
}


protocol TabBarActionDelegate {
    func menuButtonTapped()
    func presentVC(_ identifier: String)
    func switchTab(_ index: Int)
}
