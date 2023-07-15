//
//  DeviceCreateViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 27/4/2023.
//

import UIKit

class CreateDeviceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, DatabaseListener {
    
    var listenerType: ListenerType = ListenerType.all
    weak var firebaseController: FirebaseController?

    @IBOutlet weak var storageSwitch: UISwitch!
    @IBOutlet weak var rackTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var siteTextField: UITextField!
    @IBOutlet weak var deviceTypeTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var macTextField: UITextField!
    @IBOutlet weak var serialTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var rackLabel: UILabel!
    
    var allDeviceTypes: [DeviceType] = []
    var selectedDeviceType: DeviceType?
    
    var allSites: [Site] = []
    var selectedSite: Site?
    
    var allLocations: [Location] = []
    var filteredLocations: [Location] = []
    var selectedLocation: Location?
    
    var allRacks: [Rack] = []
    var filteredRacks: [Rack] = []
    var selectedRack: Rack?
    
    var deviceTypePickerView: UIPickerView!
    var sitePickerView: UIPickerView!
    var locationPickerView: UIPickerView!
    var rackPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController as? FirebaseController
        
        // TODO: Create a function for this
        
        deviceTypePickerView = UIPickerView()
        deviceTypePickerView.delegate = self
        deviceTypePickerView.dataSource = self
        let deviceTypeToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let deviceTypeFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let deviceTypeDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPickerView))
        deviceTypeToolbar.items = [deviceTypeFlexibleSpace, deviceTypeDoneButton]
        deviceTypeTextField.inputView = deviceTypePickerView
        deviceTypeTextField.inputAccessoryView = deviceTypeToolbar
        deviceTypeTextField.isUserInteractionEnabled = true
        
        sitePickerView = UIPickerView()
        sitePickerView.delegate = self
        sitePickerView.dataSource = self
        let siteToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let siteFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let siteDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPickerView))
        siteToolbar.items = [siteFlexibleSpace, siteDoneButton]
        siteTextField.inputView = sitePickerView
        siteTextField.inputAccessoryView = siteToolbar
        
        locationPickerView = UIPickerView()
        locationPickerView.delegate = self
        locationPickerView.dataSource = self
        let locationToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let locationFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let locationDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPickerView))
        locationToolbar.items = [locationFlexibleSpace, locationDoneButton]
        locationTextField.inputView = locationPickerView
        locationTextField.inputAccessoryView = locationToolbar
        
        rackPickerView = UIPickerView()
        rackPickerView.delegate = self
        rackPickerView.dataSource = self
        let rackToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let rackFlexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let rackDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPickerView))
        rackToolbar.items = [rackFlexibleSpace, rackDoneButton]
        rackTextField.inputView = rackPickerView
        rackTextField.inputAccessoryView = rackToolbar

        // Do any additional setup after loading the view.
    }
    @IBAction func storageToggle(_ sender: Any) {
        if storageSwitch.isOn {
            rackTextField.isHidden = true
            rackLabel.isHidden = true
        }
        else {
            rackTextField.isHidden = false
            rackLabel.isHidden = false
        }
    }
    
    @IBAction func createButton(_ sender: Any) {
        guard let name = nameTextField.text, !name.isEmpty else {
            let errMsg = "Please enter a name"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let serial = serialTextField.text, !serial.isEmpty else {
            let errMsg = "Please enter a serial number"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let mac = macTextField.text else {
            let errMsg = "Please enter a mac address"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let notes = notesTextField.text else {
            let errMsg = "Please enter notes"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let _ = deviceTypeTextField else {
            let errMsg = "Please select a device type"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let deviceType = selectedDeviceType else {
            let errMsg = "Selected deviceType not set"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let _ = siteTextField else {
            let errMsg = "Please select a site"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let site = selectedSite else {
            let errMsg = "Selected site not set"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let _ = locationTextField else {
            let errMsg = "Please select a location"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let location = selectedLocation else {
            let errMsg = "Selected location not set"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        if !storageSwitch.isOn {
            guard let _ = rackTextField else {
                let errMsg = "Please select a rack"
                displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
                return
            }
            guard let rack = selectedRack else {
                let errMsg = "Selected rack not set"
                displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
                return
            }
            let _ = firebaseController?.addDevice(name: name, serialNumber: serial, mac: mac, notes: notes, deviceTypeId: deviceType.id!, siteId: site.id!, locationId: location.id!, rackId: rack.id!, inStorage: storageSwitch.isOn)
            navigationController?.popViewController(animated: true)
        } else {
            // it is in storage, we do not capture rack
            let _ = firebaseController?.addDevice(name: name, serialNumber: serial, mac: mac, notes: notes, deviceTypeId: deviceType.id!, siteId: site.id!, locationId: location.id!, rackId: "", inStorage: storageSwitch.isOn)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Listeners
    
    func onDeviceTypeChange(change: DatabaseChange, deviceTypes: [DeviceType]) {
        allDeviceTypes = deviceTypes
    }
    
    func onSiteChange(change: DatabaseChange, sites: [Site]) {
        allSites = sites
    }
    
    func onLocationChange(change: DatabaseChange, locations: [Location]) {
        allLocations = locations
    }
    
    func onRackChange(change: DatabaseChange, racks: [Rack]) {
        allRacks = racks
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
    
    
    // MARK: - Picker view stuff
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == deviceTypePickerView {
            return allDeviceTypes.count
        } else if pickerView == sitePickerView {
            return allSites.count
        } else if pickerView == locationPickerView {
            return filteredLocations.count
        } else if pickerView == rackPickerView {
            return filteredRacks.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == deviceTypePickerView {
            return allDeviceTypes[row].model
        } else if pickerView == sitePickerView {
            return allSites[row].name
        } else if pickerView == locationPickerView {
            return filteredLocations[row].name
        } else if pickerView == rackPickerView {
            return filteredRacks[row].name
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == deviceTypePickerView {
            if allDeviceTypes.count > 0 {
                selectedDeviceType = allDeviceTypes[row]
                deviceTypeTextField.text = selectedDeviceType?.model
            }
        } else if pickerView == sitePickerView {
            if allSites.count > 0 {
                selectedSite = allSites[row]
                siteTextField.text = selectedSite?.name
                locationTextField.text = ""
                selectedLocation = nil
                
                // Filter the locations based on the selected site
                filteredLocations = (firebaseController?.getAllLocationsFromSiteId(selectedSite?.id))!
                locationPickerView.reloadAllComponents()
                locationTextField.isEnabled = true
            }
        } else if pickerView == locationPickerView {
            if filteredLocations.count > 0 {
                selectedLocation = filteredLocations[row]
                locationTextField.text = selectedLocation?.name
                selectedRack = nil
                
                // filter racks based on selected location
                filteredRacks = (firebaseController?.getAllRacksFromLocationId(selectedLocation?.id))!
                rackPickerView.reloadAllComponents()
                rackTextField.isEnabled = true
                
            }
        } else if pickerView == rackPickerView {
            if filteredRacks.count > 0 {
                selectedRack = filteredRacks[row]
                rackTextField.text = selectedRack?.name
            }
        }
    }
    
    @objc func dismissPickerView() {
        view.endEditing(true)
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
