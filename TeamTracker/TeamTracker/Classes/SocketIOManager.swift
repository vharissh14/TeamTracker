
//  SocketIOManager.swift
//  SocketChat
//
//  Created by Gabriel Theodoropoulos on 1/31/16.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import  SocketIO

class SocketIOManager: NSObject {
 
    static let sharedInstance = SocketIOManager()
    
    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: TeamTracker.serverHostUrl)!)

    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
    
    func subscribe(_ loggedInUser: User){
        
        let user = ["name": loggedInUser.name,
                    "teamIcon": loggedInUser.avatar,
                    "pseudoName": loggedInUser.pSeudoName,
                    "email": loggedInUser.email,
                    "phone": loggedInUser.phoneNumber,
                    "password": loggedInUser.password,
                    "mission": loggedInUser.mission,
                    "teams": loggedInUser.teamName,
                    "lat": ["lat": loggedInUser.location.latitude,
                            "lng": loggedInUser.location.longitude]
                    ] as [String : Any]
        
        socket.emit("subscribe",user)
    }
    
    func getMissionMembers(completionHandler: @escaping (_ userList: [[String: AnyObject]]) -> Void){
        socket.on("userList") { (dataArray, ack) in
            completionHandler(dataArray[0] as! [[String:AnyObject]])
        }
    }
    
    func updateLocation(pSeudoName: String, newLocation: [String : Double]){
        
        let user = ["pseudoName": pSeudoName,
                    "lat": newLocation] as [String : AnyObject]
        socket.emit("locationChanged", user)
    }
    
    func getMarkerLocationUpdates(completionHandler: @escaping (_ user: [String: AnyObject]) -> Void){
        socket.on("locationUpdate") { (dataArray, ack) in
            completionHandler(dataArray[0] as! [String: AnyObject])
        }
    }
}

