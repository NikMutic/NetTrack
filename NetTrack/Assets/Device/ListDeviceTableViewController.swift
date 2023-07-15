//
//  ListDeviceTableViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 7/5/2023.
//

import UIKit

class ListDeviceTableViewController: UITableViewController, DatabaseListener {
    var listenerType: ListenerType = ListenerType.device
    weak var firebaseController: FirebaseController?
    
    var allDevices: [Device] = []
    
    let CELL_DEVICE = "deviceCell"
    let SECTION_DEVICE = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController as? FirebaseController
    }
    
    @IBAction func optionsButtonAction(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Add actions to the dropdown menu
        let option1Action = UIAlertAction(title: "Add/Edit Manufacturers", style: .default) { _ in
            self.performSegue(withIdentifier: "showManufacturersSegue", sender: self)
        }
        alertController.addAction(option1Action)

        let option2Action = UIAlertAction(title: "Add/Edit Device Types", style: .default) { _ in
            self.performSegue(withIdentifier: "showDeviceTypesSegue", sender: self)
        }
        alertController.addAction(option2Action)
        
        let option3Action = UIAlertAction(title: "Add/Edit Sites", style: .default) { _ in
            self.performSegue(withIdentifier: "showSitesSegue", sender: self)
        }
        alertController.addAction(option3Action)
        
        let option4Action = UIAlertAction(title: "Add/Edit Locations", style: .default) { _ in
            self.performSegue(withIdentifier: "showLocationsSegue", sender: self)
        }
        alertController.addAction(option4Action)
        
        let option5Action = UIAlertAction(title: "Add/Edit Racks", style: .default) { _ in
            self.performSegue(withIdentifier: "showRacksSegue", sender: self)
        }
        alertController.addAction(option5Action)

        // Add a cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        // Configure popover presentation for iPad
        if let popoverController = alertController.popoverPresentationController {
            popoverController.barButtonItem = sender as? UIBarButtonItem
        }

        // Present the dropdown menu
        present(alertController, animated: true, completion: nil)
    }
    // MARK: - Database listeners

    func onDeviceChange(change: DatabaseChange, devices: [Device]) {
        allDevices = devices
        tableView.reloadData()
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allDevices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DEVICE, for: indexPath)

        var content = cell.defaultContentConfiguration()
        let device = allDevices[indexPath.row]
        content.text = device.name
        
        guard let inStorage = device.inStorage else {
            return cell
        }
        
        if inStorage {
            let location = firebaseController?.getLocationById(device.locationId)
            let site = firebaseController?.getSiteById(device.siteId)
            if let locationName = location?.name, let siteName = site?.name {
                let secondaryText = "In storage - \(locationName), \(siteName)"
                content.secondaryText = secondaryText
            }
        } else {
            let location = firebaseController?.getLocationById(device.locationId)
            let site = firebaseController?.getSiteById(device.siteId)
            let rack = firebaseController?.getRackById(device.rackId)
            if let siteName = site?.name, let locationName = location?.name, let rackName = rack?.name {
                let secondaryText = "\(rackName), \(locationName), \(siteName)"
                content.secondaryText = secondaryText
            }
        }
        
        
        cell.contentConfiguration = content
        cell.accessoryType = .detailButton

        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: Show device info
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        if cell.accessoryType == .detailButton {
            performSegue(withIdentifier: "showDeviceDetailsSegue", sender: indexPath)
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let device = allDevices[indexPath.row]
            firebaseController?.deleteDevice(device)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showDeviceDetailsSegue" {
            guard let destination = segue.destination as? DetailDeviceViewController,
                  let indexPath = sender as? IndexPath else {
                return
            }
            
            let selectedDevice = allDevices[indexPath.row]
            
            destination.device = selectedDevice
        }
    }
    

}
