//
//  ManufacturerListTableViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 27/4/2023.
//

import UIKit

class ListManufacturerTableViewController: UITableViewController, DatabaseListener {
    let SECTION_MANUFACTURER = 0
    
    let CELL_MANUFACTURER = "manufacturerCell"
    
    var allManufacturers: [Manufacturer] = []
    
    var listenerType = ListenerType.manufacturer
    weak var firebaseController: FirebaseController?
    
    var loggedInUser: String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController as? FirebaseController

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        // TODO: Refactor/remove this
        firebaseController?.authController.addStateDidChangeListener { [self] (auth, user) in
            // the auth state has changed. User is either logged in or logged out
            if let user = user {
                loggedInUser = user.email
                tableView.reloadData() // update UI in case it is not set before the table view is loaded
            } else {
//                print("User is not signed in")
            }
        }        
    }
    
    // MARK: - Overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        firebaseController?.removeListener(listener: self)
    }
    
    // MARK: - Database listener
    func onManufacturersChange(change: DatabaseChange, manufacturers: [Manufacturer]) {
        allManufacturers = manufacturers
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allManufacturers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let manufacturerCell = tableView.dequeueReusableCell(withIdentifier: CELL_MANUFACTURER, for: indexPath)
        
        var content = manufacturerCell.defaultContentConfiguration()
        let manufacturer = allManufacturers[indexPath.row]
        content.text = manufacturer.name
        
        manufacturerCell.contentConfiguration = content
        
        return manufacturerCell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == SECTION_MANUFACTURER {
            return true
        }
        return false
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_MANUFACTURER {
            // Delete the row from the data source
            let manufacturer = allManufacturers[indexPath.row]
            firebaseController?.deleteManufacturer(manufacturer)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

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
