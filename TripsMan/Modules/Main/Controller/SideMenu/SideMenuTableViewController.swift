//
//  SideMenuTableViewController.swift
//  TripsMan
//
//  Created by Hexeam Software Solutions on 29/12/22.
//

import UIKit

var sideMenuDelegate: SideMenuDelegate?

class SideMenuTableViewController: UITableViewController {
    
    @IBOutlet weak var sideMenuTable: UITableView!
    
    var menuItems = [SideMenuItems]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenuDelegate = self
        loadSideMenu()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        sideMenuTable.layer.masksToBounds = true
        sideMenuTable.layer.borderColor = UIColor.systemGray5.cgColor
        sideMenuTable.layer.borderWidth = 1.0
    }
    
    func loadSideMenu() {
        if SessionManager.shared.getLoginDetails() != nil {
            menuItems = [SideMenuItems(imageName: "person.circle", imageType: .systemImg, title: "Hi, \(SessionManager.shared.getLoginDetails()!.fullName!)", menuSubText: SessionManager.shared.getLoginDetails()?.username, action: .switchTab, index: 3),
                         SideMenuItems(imageName: "briefcase", imageType: .systemImg, title: "My Trips", menuSubText: "View your trips", action: .switchTab, index: 1),
                         SideMenuItems(imageName: "logout", imageType: .savedImg, title: "Logout", action: .logout)]
        } else {
            menuItems = [SideMenuItems(imageName: "person.circle", imageType: .systemImg, title: "Login / Sign Up Now", titleColor: "secondaryColor", menuSubText: "Login for best deals", action: .presentVC, identifier: "toLogin"),
                         SideMenuItems(imageName: "briefcase", imageType: .systemImg, title: "My Trips", menuSubText: "View your trips", action: .switchTab, index: 1)]
        }
        
        sideMenuTable.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sideMenuCell", for: indexPath) as! SideMenuTableViewCell
        cell.selectionStyle = .none
        
        let item = menuItems[indexPath.row]
        
        if item.imageType == .savedImg {
            cell.menuImage.image = UIImage(named: item.imageName)
        } else {
            cell.menuImage.image = UIImage(systemName: item.imageName)
        }
        
        cell.menuTitle.text = item.title
        cell.menuTitle.textColor = UIColor(named: item.titleColor ?? "primaryLabel")
        
        if item.menuSubText != nil {
            cell.menuSubText.text = item.menuSubText
        } else {
            cell.menuSubText.text = ""
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = menuItems[indexPath.row]
        if item.action == .presentVC {
            tabBarDelegate?.presentVC(item.identifier!)
        } else if item.action == .switchTab {
            tabBarDelegate?.switchTab(item.index!)
        } else if item.action == .logout {
            let alert = UIAlertController(title: "Logout", message: "Are you sure you want to Logout?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                SessionManager.shared.logout()
                tabBarDelegate?.switchTab(0)
            }))
            
            present(alert, animated: true)
        }
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SideMenuTableViewController: SideMenuDelegate {
    func updateSideMenu() {
        loadSideMenu()
    }
    
    
}

protocol SideMenuDelegate {
    func updateSideMenu()
}
