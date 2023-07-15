//
//  AccountViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 27/4/2023.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet weak var userLabel: UILabel!
    var firebaseController: FirebaseController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController
        
        firebaseController?.authController.addStateDidChangeListener { [self] (auth, user) in
            // the auth state has changed. User is either logged in or logged out
            if let user = user {
                userLabel.text = user.uid
            } else {
//                print("User is not signed in")
            }
        }

        // Do any additional setup after loading the view.
    }
    

    @IBAction func logoutButton(_ sender: Any) {
        do {
            try firebaseController?.authController.signOut()
            firebaseController?.cleanup()
            let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
            print("signed out")
//            let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//            loginViewController.modalPresentationStyle = .fullScreen
//            navigationController?.pushViewController(loginViewController, animated: true)
        } catch {
            print(error)
        }
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
