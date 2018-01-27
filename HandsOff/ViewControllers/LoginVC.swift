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
import FirebaseAuth

// Our simple login view where a user will be able to use multiple platforms to authenticate
class LoginVC: UIViewController, UINavigationControllerDelegate,UITextFieldDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    var message: String?
    var usedFirebaseLogin: Bool = false

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
        
        self.hideKeyboardWhenTappedAround()

        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        GIDSignIn.sharedInstance().uiDelegate = self
    
        //If there is a currentUser signed in, move to Custom Tab Bar Controller
        if Auth.auth().currentUser != nil && Reachability.isConnectedToNetwork() {
            self.performSegue(withIdentifier: "loginToHome", sender: self)

        }
        
    }
    
    @IBAction func bluetoothLogin(_ sender: Any) {
        message = "You have been successfully logged in."
        self.LoginSuccess(segueId: "loginToHome")
        
    }
    
    /*
     This function is called wants to Login with Email/Password.
     */
    @IBAction func didTapLogin() {
        if Auth.auth().currentUser != nil {
            // User is signed in.
        } else {
            // No user is signed in.
            Auth.auth().signIn(withEmail: emailField.text!, password: passField.text!) { (user, error) in
                if let error = error {
                    self.errorMessage(errorMsg: error.localizedDescription)
                    return
                }
                
                self.usedFirebaseLogin = true
                self.LoginSuccess(segueId: "loginToHome")


                 // Clears the textfields
                self.emailField.text? = ""
                self.passField.text? = ""
                
                // This loads the profile/Session view controller and dismisses the login view controller

            }

        }
       
    }
    
    /*
     This function is called when the user wants to login with Google Sign In.
     */
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        
        if let error = error {
            errorMessage(errorMsg: error.localizedDescription)
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                self.errorMessage(errorMsg: error.localizedDescription)
                return
            }
            //User signed in
            self.usedFirebaseLogin = true
            self.LoginSuccess(segueId: "loginToHome")

        }

    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {}
 
    /*
     This function is called when the user wants to login with FB SignIn.
     */
    @IBAction func FBLoginTouched(_ sender: Any) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                self.errorMessage(errorMsg: error.localizedDescription)
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
                    self.errorMessage(errorMsg: error.localizedDescription)
                    return
                }
                self.usedFirebaseLogin = true
                self.LoginSuccess(segueId: "loginToHome")
            })
            
        }
    }
    
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
    
    func LoginSuccess(segueId: String){
        if usedFirebaseLogin == true{
            self.message = (Auth.auth().currentUser?.email!)! + ", you have been successfully logged in."
        }
        let alertController = UIAlertController(title: "Login Success", message: self.message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) -> Void in
            alertController.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: segueId, sender: self)
        })
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
        usedFirebaseLogin = false
    }
    
    //unwind Segue To LoginVC Getter
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
}

/*
 Shared functions of all ViewControllers.
 */
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func errorMessage(errorMsg:String){
        let alertController = UIAlertController(title: "Login Error", message: errorMsg, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okayAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func logOut(segueId: String){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let alertController = UIAlertController(title: "Signout", message: "You have successfully signed out!",preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: { (action) -> Void in
                alertController.dismiss(animated: true, completion: nil)
                if segueId != ""{
                    self.performSegue(withIdentifier: segueId, sender: self)
                }
            })
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        } catch let error as NSError {
            errorMessage(errorMsg: error.localizedDescription)
            return
        }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

