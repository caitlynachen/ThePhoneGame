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

// Our simple login view where a user will be able to use multiple platforms to authenticate
class LoginVC: UIViewController, UINavigationControllerDelegate,UITextFieldDelegate {
    
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
    }
    
    /*
     This function is called when the user taps login or return in the
     password field
     */
    @IBAction func didTapLogin() {
        // Clears the textfields
        emailField.text? = ""
        passField.text? = ""
        // This loads the profile/Session view controller and dismisses the login view controller
        let customTabBarVC = self.storyboard?.instantiateViewController(withIdentifier: "TabBar") as! CustomTabBar
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.present(customTabBarVC, animated: true)
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
