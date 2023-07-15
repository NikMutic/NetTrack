//
//  ListDeviceTypeViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 2/5/2023.
//

import UIKit

class ListDeviceTypeViewController: UITableViewController, DatabaseListener {
    var listenerType: ListenerType = ListenerType.deviceType
    
    let CELL_DEVICETYPE = "deviceTypeCell"
    let SECTION_DEVICETYPE = 0
    
    weak var firebaseController: FirebaseController?
    
    var allDeviceTypes: [DeviceType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController as? FirebaseController

        // Do any additional setup after loading the view.
//        firebaseController?.authController.addStateDidChangeListener { [self] (auth, user) in
//            // the auth state has changed. User is either logged in or logged out
//            if let user = user {
//                tableView.reloadData() // update UI in case it is not set before the table view is loaded
//            } else {
//            }
//        }
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

    func onDeviceTypeChange(change: DatabaseChange, deviceTypes: [DeviceType]) {
        allDeviceTypes = deviceTypes
        tableView.reloadData()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let deviceTypeCell = tableView.dequeueReusableCell(withIdentifier: CELL_DEVICETYPE, for: indexPath)
        
        var content = deviceTypeCell.defaultContentConfiguration()
        let deviceType = allDeviceTypes[indexPath.row]
        content.text = deviceType.model
        
        let manufacturer = firebaseController?.getManufacturerById(deviceType.manufacturerId)
        content.secondaryText = manufacturer?.name
        deviceTypeCell.contentConfiguration = content
        
        return deviceTypeCell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SECTION_DEVICETYPE:
                return allDeviceTypes.count
            default:
                return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let deviceType = allDeviceTypes[indexPath.row]
            firebaseController?.deleteDeviceType(deviceType)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
