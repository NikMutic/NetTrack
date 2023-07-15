//
//  CreateRackViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 5/5/2023.
//

import UIKit

class CreateRackViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, DatabaseListener {
    var listenerType: ListenerType = ListenerType.all
    
    @IBOutlet weak var siteTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    weak var firebaseController: FirebaseController?
    
    var allSites: [Site] = []
    var selectedSite: Site?
    
    var allLocations: [Location] = []
    var filteredLocations: [Location] = []
    var selectedLocation: Location?
    
    var sitePickerView: UIPickerView!
    var locationPickerView: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController as? FirebaseController
        
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

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createButton(_ sender: Any) {
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
        guard let name = nameTextField.text, !name.isEmpty else {
            let errMsg = "Please enter a name"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        
        let _ = firebaseController?.addRack(name: name, locationId: location.id!, siteId: site.id!)
        navigationController?.popViewController(animated: true)
    }
    // MARK: - Listeners
    func onSiteChange(change: DatabaseChange, sites: [Site]) {
        allSites = sites
    }
    
    func onLocationChange(change: DatabaseChange, locations: [Location]) {
        allLocations = locations
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
        if pickerView == sitePickerView {
            return allSites.count
        } else if pickerView == locationPickerView {
            return filteredLocations.count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == sitePickerView {
            return allSites[row].name
        } else if pickerView == locationPickerView {
            return filteredLocations[row].name
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == sitePickerView {
            if allSites.count > 0 {
                selectedSite = allSites[row]
                siteTextField.text = selectedSite?.name
                locationTextField.text = ""
                nameTextField.isEnabled = false
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
                nameTextField.isEnabled = true
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
