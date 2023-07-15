//
//  DeviceTypeCreateViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 1/5/2023.
//

import UIKit

class CreateDeviceTypeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, DatabaseListener {
    
    var listenerType: ListenerType = ListenerType.manufacturer // this is manufacturer since we need to populate allManufacturers for the pickerView
    
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var manufacturerTextPickerField: UITextField!
    
    var allManufacturers: [Manufacturer] = []
    weak var firebaseController: FirebaseController?
    var selectedManufacturer: Manufacturer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController as? FirebaseController
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPickerView))
        toolbar.items = [flexibleSpace, doneButton]
        
        manufacturerTextPickerField.inputView = pickerView
        manufacturerTextPickerField.inputAccessoryView = toolbar
        
        // TODO: Add a default select an option item to the list before the manufacturers
    }
    
    @IBAction func createButton(_ sender: Any) {
        guard let _ = manufacturerTextPickerField else {
            let errMsg = "Please select a manufacturer"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let selectedManufacturer = selectedManufacturer else {
            let errMsg = "Selected manufacturer not set"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let name = modelTextField.text else {
            return
        }

        if name.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty {
                errorMsg += "- Must provide a model\n"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg, viewController: self)
            return
        }
        let _ = firebaseController?.addDeviceType(manufacturerId: selectedManufacturer.id!, model: name)
        navigationController?.popViewController(animated: true)
//        print("Selected manufacturer: \(String(describing: selectedManufacturer?.name))")
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
    
    func onManufacturersChange(change: DatabaseChange, manufacturers: [Manufacturer]) {
        allManufacturers = manufacturers
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allManufacturers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allManufacturers[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if allManufacturers.count > 0 {
            manufacturerTextPickerField.text = allManufacturers[row].name
            selectedManufacturer = allManufacturers[row]
        } else {
            
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
