//
//  LoginVC.swift
//  HandsOff
//
//  Created by Alex Blanchard on 12/27/17.
//  Copyright © 2017 Alex Blanchard. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

// Our simple login view where a user will be able to use multiple platforms to authenticate
class LoginVC: UIViewController, UINavigationControllerDelegate,UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
/*
     These are the connections to the storyboard!
     They allow for direct manipulation through code.
     */
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    
    /*
     This is function is called on every view controller and initiates
     the view. We also call a custom function to control some behavior.
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        setupView()
    }
    
    /*
     Here we set the delegates of the textfields to this
     view controller i.e. self. This allows us to use delegate functions
     to customize the behavior of the view and text input. You'll notice the
     keyboard comes up automatically and as you tap return it brings you to the next field.
     On the final field however it simply runs the login buttons function
     */
    func setupView() {
        emailField.delegate = self
        passField.delegate = self
        emailField.becomeFirstResponder()
        self.navigationController?.navigationBar.isHidden = true
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
    
        if Auth.auth().currentUser != nil {
            // User is signed in.
            self.performSegue(withIdentifier: "loginToHome", sender: self)

        }
        
    }
    
    /*
     This function is called when the user taps login or return in the
     password field
     */
    @IBAction func signOutTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("signed out")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)

            let alertController = UIAlertController(title: "Signout Error", message: signOutError.localizedDescription, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
    }
    
    //
    @IBAction func didTapLogin() {
        if Auth.auth().currentUser != nil {
            // User is signed in.
        } else {
            // No user is signed in.
            Auth.auth().signIn(withEmail: emailField.text!, password: passField.text!) { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                print("\(user!.email!) logged in")
                
                 // Clears the textfields
                self.emailField.text? = ""
                self.passField.text? = ""
                
                // This loads the profile/Session view controller and dismisses the login view controller
                self.performSegue(withIdentifier: "loginToHome", sender: self)

            }
        }
       
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            print("Launch error: \(error.localizedDescription)")
            let alertController = UIAlertController(title: "Launch Error", message: error.localizedDescription, preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Login error: \(error.localizedDescription)")
                let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            //User signed in
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
 
    @IBAction func FBLoginTouched(_ sender: Any) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
          
                self.performSegue(withIdentifier: "loginToHome", sender: self)

            })
            
        }
    }
    
    
    //TODO: FireBase calls
    // This is where Firebase returns tokens and we load up a session id
    
    
    //MARK: Delegate methods
    
    // This is where those delegate assignments come in handy. Events in the textfields
    // handled here. Like hitting the return key.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            passField.becomeFirstResponder()
            break
        case passField:
            didTapLogin()
            break
        default:
            print("This can't happen")
        }
        return true
    }
    //TODO: User input methods
    // Function for user input checks
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
