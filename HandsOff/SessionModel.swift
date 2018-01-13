//
//  SessionModel.swift
//  HandsOff
//
//  Created by Caitlyn Chen on 1/11/18.
//  Copyright © 2018 Alex Blanchard. All rights reserved.
//


import Foundation
import Firebase

struct SessionModel {
    
    let key: String
    let hostUser: String
    let inSession: String
    let terms: String
    
    
    let ref: DatabaseReference?
    
    init(hostUser: String, inSession: String, terms: String, key: String) {
        self.key = key
        
        self.hostUser = hostUser
        self.inSession = inSession
        self.terms = terms
        
        self.ref = nil
        
    }
    
    init(snapshot: DataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        hostUser = snapshotValue["hostUser"] as! String
        inSession = snapshotValue["inSession"] as! String
        terms = snapshotValue["terms"] as! String

        
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "hostUser": hostUser,
            "inSession": inSession,
            "terms": terms,
            "key": key
        ]
        
    }
}

