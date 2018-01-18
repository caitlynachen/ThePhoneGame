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
import MultipeerConnectivity

// Our sesssions view that allows the user to host or join a session
class SessionVC: UIViewController,MCSessionDelegate, MCBrowserViewControllerDelegate  {
    
    // Outlets/Connections to storyboard again.
    @IBOutlet weak var hostBtn: CustomButton!
    @IBOutlet weak var joinBtn: CustomButton!
    @IBOutlet weak var phoneDownLbl: UILabel!
    @IBOutlet weak var debugLabel: UILabel!
    
    var ref: DatabaseReference?
    var notInSessionRef: DatabaseReference?
    
    var currentUserSession: SessionModel?
    var sessionRef: DatabaseReference?
    
    /*
     This assigns an object to a variable allowing us
     access to the devices movement mechanics. Gyroscope, accelerometer...
     */
    let motionManager: CMMotionManager = CMMotionManager()
    var terms = 0
    
    var peerID: MCPeerID!
    var peerIDCollection: Set<MCPeerID>!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    var sessionStarted: Bool!
    var isConnected: Bool!
    var gameInProgress: Bool!
    var isHost: Bool!
    var didJoin: Bool!
    
    var isFirebaseAvailable: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Reachability.isConnectedToNetwork() && Auth.auth().currentUser != nil{
            print("Internet Connection Available!")
            isFirebaseAvailable = true
        }else{
            print("Internet Connection not Available!")
            isFirebaseAvailable = false
        }
        
        setupSessionProperties()
        
        /*
         // This displays a welcome message with the users name. Currently turned off for debugging
         let ac = UIAlertController(title: "Welcome", message: "Host or Join a session", preferredStyle: .alert)
         ac.addAction(UIAlertAction(title: "OK", style: .cancel))
         present(ac, animated: true)
         */
    }
    
    func setupSessionProperties() {
        //firebase
        if isFirebaseAvailable == true {
            ref = Database.database().reference().child("sessions")
            notInSessionRef = Database.database().reference().child("notInSession")
        } else{
            //bluetooth
            peerID = MCPeerID(displayName: UIDevice.current.name)
            peerIDCollection = []
            mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .none)
            mcSession.delegate = self
            mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "thephonegame", discoveryInfo: nil, session: mcSession)
            sessionStarted = false
            isConnected = peerIDCollection.count > 0
            gameInProgress = false
        }
    }
    
    // A simple animation function to display the "Put phone down" message and a delay to give them 5 seconds to do so
    func performAnimation() {
        phoneDownLbl.alpha = 0
        
        UIView.animate(withDuration: 5.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.debugLabel.isHidden = false
            self.debugLabel.text = "Session starting..."
            self.phoneDownLbl.isHidden = false
            self.phoneDownLbl.center = CGPoint(x: 200, y: 90 + 200)
            self.phoneDownLbl.alpha = 1
        }, completion: { _ in
            self.startMotionDetection()
            self.sessionStarted = true
            self.phoneDownLbl.isHidden = true
            self.debugLabel.text = "Session in progress..."
        })
    }
    
    // Here we launch the device movement data collection and use the data to check if the phone has been moved.
    func startMotionDetection() {
        
        motionManager.accelerometerUpdateInterval = 0.5
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let data = data {
                let zData = abs(data.acceleration.z)
                let xData = abs(data.acceleration.x)
                let yData = abs(data.acceleration.y)
                
                if zData > 1 || xData > 0.5 || yData > 0.5 {
                    self.didMoveDevice()
                    self.debugLabel.text = "Session Ended"
                    self.sendData()
                }
            } else {
                print("CoreMotion error! : \(error!)")
            }
        }
    }
    
    func enableGUI() {
        self.hostBtn.isHidden = false
        self.joinBtn.isHidden = false
        self.hostBtn.isEnabled = true
        self.joinBtn.isEnabled = true
    }
    
    func disableGUI() {
        self.hostBtn.isHidden = true
        self.joinBtn.isHidden = true
        self.hostBtn.isEnabled = false
        self.joinBtn.isEnabled = false
    }
    
    func sendData() {
        let data = "\(sessionStarted!)".data(using: .utf8)
        print(data)
        do {
            print(data!)
            print("sendData()")
            try mcSession.send(data!, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        }
    }
    
    func didMoveDevice() {
        let ac = UIAlertController(title: "Pony Up!", message: "Please pay the penalty terms", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Pay", style: .default) { _ in
            //TODO: Apple Pay
            self.sessionStarted = false
            self.didPressPay()
            self.enableGUI()
            self.debugLabel.isHidden = false
            self.debugLabel.text = "Host or Join"
        })
        ac.addAction(UIAlertAction(title: "Don't Pay", style: .cancel) { _ in
            self.sessionStarted = false
            self.enableGUI()
            self.debugLabel.isHidden = false
            self.debugLabel.text = "Host or Join"
        })
        self.present(ac, animated: true)
        self.motionManager.stopAccelerometerUpdates()
        self.mcSession.disconnect()
    }
    
    
    // This displays the terms sheet and allows the user to start the session. It also animates the view a bit and creates a session in Firebase.
    func sessionStart() {
        let ac = UIAlertController(title: "Enter Terms", message: "Only enter numbers", preferredStyle: .alert)
        ac.addTextField()
        ac.textFields![0].keyboardType = .numberPad
        ac.addAction(UIAlertAction(title: "Start Session", style: .default) { alert in
            self.disableGUI()
            self.debugLabel.isHidden = true
            self.performAnimation()
            print(self.mcSession.connectedPeers.count)
            if self.mcSession.connectedPeers.count > 0 {
                self.sendData()
            }
            self.terms = Int(ac.textFields![0].text!)!
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        
    }
    
    
    // Runs when the host button is pressed
    @IBAction func didtapHostBtn(_ sender: Any) {
        sessionStart()
        
        //firebase
        if isFirebaseAvailable == true {
            hostSessionWithFirebase()
        } else{
            //bluetooth
            startBTHostingSession()
        }
        
    }
    
    //MARK: BlueTooth Session
    func startBTHostingSession() {
        if !sessionStarted {
            mcAdvertiserAssistant.start()
            sessionStarted = true
            let ac = UIAlertController(title: "Hosting", message: "Players can now join your session", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] _ in self.debugLabel.text = "Hosting..." })
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Hosting in Progress", message: "Players can still join your session", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self] _ in self.debugLabel.text = "Hosting..." })
            present(ac, animated: true)
        }
    }
    
    func hostSessionWithFirebase(){
        self.sessionRef = self.ref?.childByAutoId()
        let sessionModel = SessionModel(hostUser: (Auth.auth().currentUser?.email)!, inSession: "true", terms: "\(terms)", key: (self.sessionRef?.key)!)
        self.sessionRef?.setValue(sessionModel.toAnyObject())
        
        self.currentUserSession = sessionModel
        
    }
    
    var hostSessionToJoin: String?
    // Runs when the join button is pressed
    @IBAction func didTapJoinBtn(_ sender: Any) {
        if isFirebaseAvailable == true {
            let ac = UIAlertController(title: "Enter Host's Email", message: nil, preferredStyle: .alert)
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "Join a Session", style: .default, handler: {
                alert in
                
                self.hostSessionToJoin =  ac.textFields![0].text!
                
                //firebase
                self.joinSessionWithFirebase()
    
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        } else {
            //bluetooth
            self.joinBTSession()
        }
    }
    
    func joinSessionWithFirebase(){
        self.ref?.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            for i in snapshot.children {
                let sModel = SessionModel(snapshot: i as! DataSnapshot)
                if (sModel.hostUser == self.hostSessionToJoin){
                    self.currentUserSession = sModel
                    
                    let datasnap = i as! DataSnapshot
                    self.sessionRef = datasnap.ref
                    
                    let joinedRef = datasnap.ref.child("joinedUsers")
                    
                    joinedRef.childByAutoId().setValue(Auth.auth().currentUser?.email!)
                    self.disableGUI()
                    self.debugLabel.isHidden = true
                    self.performAnimation()
                    
                } else{
                    let ac = UIAlertController(title: "Session Not Available", message: "This host user is not currently holding a session.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .cancel))
                    self.present(ac, animated: true)
                }
            }
        })
    }
    
    func joinBTSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "thephonegame", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
        mcAdvertiserAssistant?.stop()
        sessionStarted = false
    }
    
    
    // If the user decides to pay the penalty, we display the payment view.
    func didPressPay() {
        self.performSegue(withIdentifier: "sessionToPayment", sender: self)
        
    }
    
    //transfer currentUserSessionModel to Payment screen in order to provide info on who to pay and the terms
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sessionToPayment"{
            
            let destVC = segue.destination as! PaymentVC
            destVC.currentUserSession = currentUserSession
        }
    }
    
    
    //MARK: Multipeer Connectivity Delegate Methods
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Recieved")
        if let str = String(data: data, encoding: String.Encoding.utf8) {
            if str == "true" {
                DispatchQueue.main.async { [unowned self] in
                    self.disableGUI()
                    self.performAnimation()
                }
            } else {
                print(str.description)
            }
        }
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            let ac = UIAlertController(title: "Connectiion Succeeded!", message: "You Successfully connected to \(peerID.displayName)", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
            if isConnected {
                let ac = UIAlertController(title: "\(peerID.displayName) left the session", message: nil, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(ac, animated: true, completion: nil)
            } else {
                let ac = UIAlertController(title: "Connection Failed", message: "Please attempt connection again", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                present(ac, animated: true, completion: nil)
            }
        }
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        if mcAdvertiserAssistant.session.connectedPeers.count > 0 {
            debugLabel.text = "Joined"
            self.disableGUI()
            self.performAnimation()
        }else {
            debugLabel.text = "The Phone Game"
        }
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        debugLabel.text = "Host or Join"
        dismiss(animated: true)
    }
}
