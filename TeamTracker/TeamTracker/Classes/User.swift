//
//  User.swift
//  TeamTracker
//
//  Created by Shaik on 23/10/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

import UIKit
import GoogleMaps

class User: NSObject {
    let name: String
    let avatar: String
    let pSeudoName: String
    let email: String
    let phoneNumber: String
    let password: String
    let teamName: String
    var mission: String
    var location: CLLocationCoordinate2D
    
    override init() {
        self.name = ""
        self.avatar = ""
        self.pSeudoName = ""
        self.email = ""
        self.phoneNumber = ""
        self.password = ""
        self.mission = ""
        self.teamName = ""
        self.location = TeamTracker.defaultLocation
    }
    init(user: [String: Any]) {
        self.name = user["name"] as? String ?? ""
        self.avatar = user["teamIcon"] as? String ?? ""
        self.pSeudoName = user["pseudoName"] as? String ?? ""
        self.email = user["email"] as? String ?? ""
        self.phoneNumber = user["phone"] as? String ?? ""
        self.password = user["password"] as? String ?? ""
        self.mission = user["mission"] as? String ?? ""
        self.teamName = user["teams"] as? String ?? ""
        self.location = user["location"] as? CLLocationCoordinate2D ?? TeamTracker.defaultLocation
    }
}

