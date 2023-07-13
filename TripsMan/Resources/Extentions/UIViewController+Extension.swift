//
//  UIViewControllerExtenstions.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 06/09/22.
//

import Foundation
import UIKit
import SideMenu
import CoreLocation
import MapKit

var activityIndicator = UIActivityIndicatorView()
var tabBarDelegate: TabBarActionDelegate?

extension UIViewController {

    //Hide keyboard on tap
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addMenuButton(with title: String, isHome: Bool = false) {
        let logo = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        let logoView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        logoView.image = UIImage(named: "logo-icon")
        logoView.contentMode = .scaleAspectFit
        logo.customView = logoView
        let menuButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(menu))
        menuButton.image = UIImage(named: "icon-menu")
        self.tabBarController?.navigationItem.leftBarButtonItems = [menuButton, logo]
        if !isHome {
            self.tabBarController?.navigationItem.rightBarButtonItems = nil
        }
        self.tabBarController?.navigationItem.title = title
        
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "tabBarBackground")
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.black
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        self.tabBarController?.tabBar.standardAppearance = tabBarAppearance
        self.tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
    }
    
    func addBackButton(with title: String, toVc: Int? = nil) {
        let logo = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        let logoView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 30, height: 40))
        logoView.image = UIImage(named: "logo-icon")
        logoView.contentMode = .scaleAspectFit
        logo.customView = logoView
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(back))
        if let toVc = toVc {
            backButton.tag = toVc
            backButton.action = #selector(backToVc)
        }
        backButton.image = UIImage(systemName: "chevron.backward")
        self.tabBarController?.navigationItem.leftBarButtonItems = [backButton, logo]
        self.tabBarController?.navigationItem.rightBarButtonItems = nil
        self.tabBarController?.navigationItem.title = title
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func backToVc(_ sender: UIButton) {
        let vc = self.navigationController?.viewControllers[sender.tag]
        if let vc = vc {
            self.navigationController?.popToViewController(vc, animated: true)
        }
    }
    
    @objc func menu() {
        tabBarDelegate?.menuButtonTapped()
    }
    
    func showIndicator() {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator = UIActivityIndicatorView(frame: self.view.frame)
            activityIndicator.center = self.view.center
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = .medium
            activityIndicator.startAnimating()
            self.view.addSubview(activityIndicator)
            self.view.isUserInteractionEnabled = false
        }
    }
    
    func hideIndicator() {
        DispatchQueue.main.async {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func getDateRange(from: Date, to: Date) -> String {
        let intervalFormatter = DateIntervalFormatter()
        intervalFormatter.timeStyle = .none
        intervalFormatter.dateStyle = .medium
        return intervalFormatter.string(from: from, to: to)
    }
    
    func getDateRange(from: Date, totalDays: Int) -> String {
        let intervalFormatter = DateIntervalFormatter()
        intervalFormatter.timeStyle = .none
        intervalFormatter.dateStyle = .medium
        let to = from.adding(minutes: 1440*(totalDays-1))
        return intervalFormatter.string(from: from, to: to)
    }
    
    func openInMap(latitude: Double, longitude: Double, name: String) {
        let latitude: CLLocationDegrees = latitude
        let longitude: CLLocationDegrees = longitude
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }
}

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}


