//
//  SettingsVC.swift
//  HandsOff
//
//  Created by Alex Blanchard on 12/26/17.
//  Copyright © 2017 Alex Blanchard. All rights reserved.
//

import Foundation
import UIKit
import Firebase

// Our humble settings view that allows the user to logout
class SettingsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /*
     This function is called when the user wants to log out.
     */
    @IBAction func didTapLogout(_ sender: Any) {
        if Reachability.isConnectedToNetwork() && Auth.auth().currentUser != nil{
            logOut(segueId: "unwindToLogin")

        } else{
            //logout via Bluetooth
        }

    }
}
