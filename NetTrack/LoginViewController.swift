//
//  LoginViewController.swift
//  NetTrack
//
//  Created by Nikola Mutic on 27/4/2023.
//

import UIKit
import Firebase
import FirebaseFirestoreSwift

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var firebaseController: FirebaseController?
    var authHandle: AuthStateDidChangeListenerHandle?
    var loggedInUser: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        firebaseController = appDelegate?.firebaseController

        // check for login
        authHandle = firebaseController?.authController.addStateDidChangeListener { (auth, user) in
            // the auth state has changed. User is either logged in or logged out
            if let user = user {
                print("Logged in as \(user.email!)")
                self.loggedInUser = user.email!
//                self.performSegue(withIdentifier: "showTabControllerSegue", sender: nil)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let tabBarController = storyboard.instantiateViewController(withIdentifier: "tabBarController")
                tabBarController.modalPresentationStyle = .fullScreen
                self.present(tabBarController, animated: true, completion: nil)
            } else {
//                print("User is not signed in")
                self.firebaseController?.cleanup()
            }
        }
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            return
        }
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: email) {
            displayMessage(title: "error", message: "Invalid email", viewController: self)
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayMessage(title: "error", message: "password cannot be empty", viewController: self)
            return
        }
        print("clicked login button")
        firebaseController?.login(email: email, password: password)
    }
    
    @IBAction func signupButtonAction(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            return
        }
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        
        if !emailPredicate.evaluate(with: email) {
            displayMessage(title: "error", message: "Invalid email", viewController: self)
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            displayMessage(title: "error", message: "password cannot be empty", viewController: self)
            return
        }
        print("clicked sign up button")
        firebaseController?.signup(email: email, password: password)
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
