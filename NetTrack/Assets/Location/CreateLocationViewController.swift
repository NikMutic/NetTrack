//
//  CreateLocationViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 3/5/2023.
//

import UIKit

class CreateLocationViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, DatabaseListener {
    var listenerType: ListenerType = ListenerType.site

    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var siteTextField: UITextField!
    
    weak var firebaseController: FirebaseController?
    
    var allSites: [Site] = []
    var selectedSite: Site?
    
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
        
        siteTextField.inputView = pickerView
        siteTextField.inputAccessoryView = toolbar

        // Do any additional setup after loading the view.
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
    
    @IBAction func createButton(_ sender: Any) {
        guard let _ = siteTextField else {
            let errMsg = "Please select a site"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let selectedSite = selectedSite else {
            let errMsg = "Selected site not set"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let name = nameTextField.text, !name.isEmpty else {
            let errMsg = "Please enter a name"
            displayMessage(title: "Not all fields filled", message: errMsg, viewController: self)
            return
        }
        guard let notes = notesTextField.text else {
            return
        }

        let _ = firebaseController?.addLocation(siteId: selectedSite.id!, name: name, notes: notes)
        navigationController?.popViewController(animated: true)
    }
    
    func onSiteChange(change: DatabaseChange, sites: [Site]) {
        allSites = sites
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allSites.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allSites[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if allSites.count > 0 {
            siteTextField.text = allSites[row].name
            selectedSite = allSites[row]
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
