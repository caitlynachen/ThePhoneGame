//
//  PaymentVC.swift
//  HandsOff
//
//  Created by Alex Blanchard on 12/31/17.
//  Copyright © 2017 Alex Blanchard. All rights reserved.
//

import Foundation
import UIKit
import PassKit

// This is where we pony up!
class PaymentVC: UIViewController {
    
    var currentUserSession: SessionModel?
    
    //TODO: Implement Apple Pay
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToSession", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PaymentToVenmo"{
            
            let destVC = segue.destination as! VenmoWebVC
            destVC.currentUserSession = currentUserSession
        }
    }
}
