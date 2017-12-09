//
//  TeamTracker.swift
//  TeamTracker
//
//  Created by Shaik on 15/11/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

import UIKit
import GoogleMaps

class TeamTracker: NSObject {
    
    static let sharedInstance = TeamTracker()
    static let serverHostUrl = "https://teamtracker.riverway.in"
    //static let serverHostUrl = "http://192.168.1.7:3000"
    static let defaultLocation = CLLocationCoordinate2D(latitude: 12.965429, longitude: 77.714270)
    
    static func validateUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
}
