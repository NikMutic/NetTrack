//
//  CreateSiteViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 3/5/2023.
//

import UIKit

class CreateSiteViewController: UIViewController {

    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    weak var firebaseController: FirebaseController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController

        // Do any additional setup after loading the view.
    }
    
    @IBAction func createButton(_ sender: Any) {
        guard let name = nameTextField.text else {
            displayMessage(title: "Not all fields filled", message: "Please enter name", viewController: self)
            return
        }
        
        guard let address = addressTextField.text else {
            displayMessage(title: "Not all fields filled", message: "Please enter address", viewController: self)
            return
        }
        
        let _ = firebaseController?.addSite(name: name, address: address)
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
