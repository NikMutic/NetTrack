//
//  ListPrefixViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 16/5/2023.
//

import UIKit

class ListPrefixViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func showDropdownMenu(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // Add actions to the dropdown menu
        let option1Action = UIAlertAction(title: "Add/Edit VLANs", style: .default) { _ in
            // Handle Option 1 selection
        }
        alertController.addAction(option1Action)

        let option2Action = UIAlertAction(title: "Add/Edit Prefix Types", style: .default) { _ in
            // Handle Option 2 selection
        }
        alertController.addAction(option2Action)

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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
