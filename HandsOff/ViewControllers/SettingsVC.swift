//
//  SettingsVC.swift
//  HandsOff
//
//  Created by Alex Blanchard on 12/26/17.
//  Copyright © 2017 Alex Blanchard. All rights reserved.
//

import Foundation
import UIKit

// Our humble settings view that allows the user to logout
class SettingsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Called when logout is touched
    @IBAction func didTapLogout(_ sender: Any) {
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.present(loginViewController, animated: true)
    }
}
