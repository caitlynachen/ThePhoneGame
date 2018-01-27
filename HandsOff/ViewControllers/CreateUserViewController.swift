//
//  CreateUserViewController.swift
//  HandsOff
//
//  Created by Caitlyn Chen on 1/8/18.
//  Copyright © 2018 Alex Blanchard. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class CreateUserViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passWordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /*
     This function is called when the user wants to create a new user using Email/Password method.
     */
    @IBAction func createUserButtonTapped(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passWordTextField.text!) { (user, error) in
            
            if let error = error {
                self.errorMessage(errorMsg: error.localizedDescription)
                return
            }
            print("\(user!.email!) created")
            self.performSegue(withIdentifier: "toSessionView", sender: self)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToLoginFromCreateUser", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
