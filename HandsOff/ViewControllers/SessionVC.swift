//
//  SessionVC.swift
//  HandsOff
//
//  Created by Alex Blanchard on 12/26/17.
//  Copyright © 2017 Alex Blanchard. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import Firebase
import FirebaseDatabase

// Our sesssions view that allows the user to host or join a session
class SessionVC: UIViewController {
    
    // Outlets/Connections to storyboard again.
    @IBOutlet weak var hostBtn: CustomButton!
    @IBOutlet weak var joinBtn: CustomButton!
    @IBOutlet weak var sessionInProLbl: UILabel!
    @IBOutlet weak var phoneDownLbl: UILabel!
    
    var ref: DatabaseReference?
    /*
     This assigns an object to a variable allowing us
     access to the devices movement mechanics. Gyroscope, accelerometer...
     */
    let motionManager: CMMotionManager = CMMotionManager()
    var terms = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference().child("sessions")
        
        
        
        
        /*
         // This displays a welcome message with the users name. Currently turned off for debugging
         let ac = UIAlertController(title: "Welcome", message: "Host or Join a session", preferredStyle: .alert)
         ac.addAction(UIAlertAction(title: "OK", style: .cancel))
         present(ac, animated: true)
         */
    }
    
    // This displays the terms sheet and allows the user to start the session. It also animates the view a bit and creates a session in Firebase.
    func sessionStart() {
        let ac = UIAlertController(title: "Enter Terms", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Terms"
        }
        ac.addAction(UIAlertAction(title: "Start Session", style: .default) { alert in
            self.hostBtn.isHidden = true
            self.joinBtn.isHidden = true
            self.hostBtn.isEnabled = false
            self.joinBtn.isEnabled = false
            self.performAnimation()
            
            let sessionModel = SessionModel(hostUser: (Auth.auth().currentUser?.email)!, inSession: "true", terms: ac.textFields![0].text!, key: "")
            let sessionRef = self.ref?.childByAutoId()
            
            sessionRef?.setValue(sessionModel.toAnyObject())
            
            
            
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
        
    }
    
    // A simple animation function to display the "Put phone down" message and a delay to give them 5 seconds to do so
    func performAnimation() {
        phoneDownLbl.alpha = 0
        UIView.animate(withDuration: 5.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.phoneDownLbl.center = CGPoint(x: 200, y: 90 + 200)
            self.phoneDownLbl.alpha = 1
        }, completion: { _ in
            self.startMotionDetection()
            self.sessionInProLbl.isHidden = false
            self.phoneDownLbl.alpha = 0
        })
    }
    
    // Here we launch the device movement data collection and use the data to check if the phone has been moved.
    func startMotionDetection() {
        //FIXME: Needs a more precise method of detection with yaw pitch and roll checks
        motionManager.accelerometerUpdateInterval = 0.5
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let data = data {
                if abs(data.acceleration.z) > 1 || abs(data.acceleration.x) > 0.5 || abs(data.acceleration.y) > 0.5 {
                    print("Moved!! Pony up!")
                    let ac = UIAlertController(title: "Pony Up!", message: "Please pay the penalty terms", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Pay", style: .default) { _ in
                        //TODO: Apple Pay
                        self.didPressPay()
                        self.hostBtn.isHidden = false
                        self.joinBtn.isHidden = false
                        self.hostBtn.isEnabled = true
                        self.joinBtn.isEnabled = true
                    })
                    ac.addAction(UIAlertAction(title: "Don't Pay", style: .cancel) { _ in
                        self.hostBtn.isHidden = false
                        self.joinBtn.isHidden = false
                        self.hostBtn.isEnabled = true
                        self.joinBtn.isEnabled = true
                    })
                    self.present(ac, animated: true)
                    self.motionManager.stopAccelerometerUpdates()
                    self.sessionInProLbl.isHidden = true
                }
            } else {
                print(error)
            }
        }
    }
    
    // If the user decides to pay the penalty, we display the payment view.
    func didPressPay() {
        let payVC = self.storyboard?.instantiateViewController(withIdentifier: "PaymentVC")
        self.navigationController?.pushViewController(payVC!, animated: true)
    }
    
    // Runs when the host button is pressed
    @IBAction func didtapHostBtn(_ sender: Any) {
        sessionStart()
    }
    
    // Runs when the join button is pressed
    @IBAction func didTapJoinBtn(_ sender: Any) {
        let ac = UIAlertController(title: "Enter Session id", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Join a Session", style: .default, handler: {
            alert in
            
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}
