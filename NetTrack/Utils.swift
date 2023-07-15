//
//  Utils.swift
//  NetTrack
//
//  Created by Nikola Mutic on 29/4/2023.
//

import UIKit

func displayMessage(title: String, message: String, viewController: UIViewController) {
    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
    viewController.present(alertController, animated: true, completion: nil)
}
