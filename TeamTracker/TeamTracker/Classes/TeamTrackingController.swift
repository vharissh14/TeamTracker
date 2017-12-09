//
//  TeamTrackingController.swift
//  TeamTracker
//
//  Created by Shaik on 23/10/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

import UIKit
import GoogleMaps

class TeamTrackingController: UIViewController {
    
    var currentUser = User()
    var userList = [User]()
    var locationManager = CLLocationManager()
    var markerDict: [String: GMSMarker] = [:]
    var currentUsertMarker = GMSMarker()
    var location: [String: Double] = [:]
    
    lazy var mapView: GMSMapView = {
        let camera = GMSCameraPosition.camera(withTarget: TeamTracker.defaultLocation, zoom: 10)
        let mapview = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapview.isMyLocationEnabled = true
        mapview.delegate = self
        mapview.translatesAutoresizingMaskIntoConstraints = false
        return mapview
    }()
    
    let footerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        GMSServices.provideAPIKey("AIzaSyDzgSjuctiaOLdu41j_OJBI3USyUbYomjU")
        
        view.addSubview(footerView)
        view.addSubview(mapView)
        
        setupNavigationBar()
        customizeFooterView()
        setupMapview()
        setupLocationManager()
        customizeCurrentUserMarker()
        subscribeCurrentUserToNodeJS()
        getEventParticipants()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SocketIOManager.sharedInstance.getMarkerLocationUpdates { (userToUpdate) in
            print("\n\n\nuser to update: \n")
            print(userToUpdate)
            let pSeudoName = userToUpdate["pseudoName"] as? String
            let locationDict = userToUpdate["lat"]!
            guard let lat = locationDict["lat"]!, let lng = locationDict["lng"]! else { return }
            let newlocation = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: lng as! CLLocationDegrees)
            let marker = self.markerDict[pSeudoName!]
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            marker?.position = newlocation
            marker?.map = self.mapView
            CATransaction.commit()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        if UIDevice.current.orientation.isLandscape {
            print("landscape")
            delegate.statusBarBackgroundView?.isHidden = true
            
        } else {
            print("portrait")
            delegate.statusBarBackgroundView?.isHidden = false
            
        }
    }

}
