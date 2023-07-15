//
//  ListSiteTableViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 2/5/2023.
//

import UIKit

class ListSiteTableViewController: UITableViewController, DatabaseListener {
    var listenerType: ListenerType = ListenerType.site
    weak var firebaseController: FirebaseController?

    var allSites: [Site] = []
    
    let SECTION_SITE = 0
    let CELL_SITE = "siteCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController as? FirebaseController

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    
    
    
    // MARK: - Database Listeners
    func onSiteChange(change: DatabaseChange, sites: [Site]) {
        allSites = sites
        tableView.reloadData()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let siteCell = tableView.dequeueReusableCell(withIdentifier: CELL_SITE, for: indexPath)

        var content = siteCell.defaultContentConfiguration()
        let site = allSites[indexPath.row]
        content.text = site.name
        content.secondaryText = site.address
        
        siteCell.contentConfiguration = content

        return siteCell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let site = allSites[indexPath.row]
            firebaseController?.deleteSite(site)
        }
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
