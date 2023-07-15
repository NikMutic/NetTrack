//
//  ManufacturerCreateViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 29/4/2023.
//

import UIKit

class CreateManufacturerViewController: UIViewController {
    weak var firebaseController: FirebaseController?
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController

    }
    

    @IBAction func createButton(_ sender: Any) {
        guard let name = nameTextField.text else {
            return
        }
        
        if name.isEmpty {
            var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty {
                errorMsg += "- Must provide a name\n"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg, viewController: self)
            return
        }
        
        let _ = firebaseController?.addManufacturer(name: name)
        navigationController?.popViewController(animated: true)
        
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
