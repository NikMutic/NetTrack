//
//  ListRackTableViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 4/5/2023.
//

import UIKit

class ListRackTableViewController: UITableViewController, DatabaseListener {
    var listenerType: ListenerType = ListenerType.rack
    weak var firebaseController: FirebaseController?
    
    var allRacks: [Rack] = []
    var allLocations: [Location] = []
    var allSites: [Site] = []
    
    let CELL_RACK = "rackCell"
    let SECTION_RACK = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController as? FirebaseController
    }
    
    // MARK: - Database listeners
    func onRackChange(change: DatabaseChange, racks: [Rack]) {
        allRacks = racks
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRacks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_RACK, for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        let rack = allRacks[indexPath.row]
        content.text = rack.name
        
        let location = firebaseController?.getLocationById(rack.locationId)
        let site = firebaseController?.getSiteById(rack.siteId)
        if let siteName = site?.name, let locationName = location?.name {
            let secondaryText = "\(siteName) - \(locationName)"
            content.secondaryText = secondaryText
        }
        
        cell.contentConfiguration = content

        // Configure the cell...

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Show devices in that rack
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let rack = allRacks[indexPath.row]
            firebaseController?.deleteRack(rack)
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
    
    // MARK: - Overrides
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firebaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        firebaseController?.removeListener(listener: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
