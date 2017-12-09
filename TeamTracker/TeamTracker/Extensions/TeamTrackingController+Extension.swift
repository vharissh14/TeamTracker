//
//  TeamTrackingController+Extension.swift
//  TeamTracker
//
//  Created by Shaik on 15/11/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

import UIKit
import GoogleMaps
import Social

extension TeamTrackingController: GMSMapViewDelegate, CLLocationManagerDelegate {
    
    func getEventParticipants(){
        SocketIOManager.sharedInstance.getMissionMembers { (loggedInUsers) in
            self.userList = [User]()
            
            for loggedInUser in loggedInUsers{
                if loggedInUser["pseudoName"] as? String == self.currentUser.pSeudoName{
                    print("****************************\nname: \(self.currentUser.name)\nEvent: \(self.currentUser.mission)")
                    continue
                }
                let locationDict = loggedInUser["lat"]!
                guard let lat = locationDict["lat"]!, let lng = locationDict["lng"]! else { return }
                let location = CLLocationCoordinate2D(latitude: lat as! CLLocationDegrees, longitude: lng as! CLLocationDegrees)
                
                let userObj = User(user: loggedInUser)
                userObj.location = location
                self.userList.append(userObj)
                print("****************************\nname: \(userObj.name)\nEvent: \(userObj.mission)")
            }
            print("****************************")
            self.customizeEventParticipantsMarkers()
        }
    }
    
    func subscribeCurrentUserToNodeJS(){
        SocketIOManager.sharedInstance.subscribe(currentUser)
    }
    
    func customizeCurrentUserMarker(){
        currentUsertMarker = GMSMarker()
        currentUsertMarker.position = TeamTracker.defaultLocation
        currentUsertMarker.title = currentUser.name
        currentUsertMarker.snippet = "MobileNo: \(currentUser.phoneNumber)"
      
        if !(TeamTracker.validateUrl(urlString: currentUser.avatar)) {
            self.setupMarker(currentUsertMarker, With: UIImage(named: "DefaultMarkerIcon")!)
        }
        else{
            let imageURL = URL(string: currentUser.avatar)
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                if let err = error{
                    print(err.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        self.alert(title: "Error", msg: "\(err.localizedDescription)")
                    })
                    return
                }
                DispatchQueue.main.async(execute: {
                    if let downloadImage = UIImage(data: data!){
                        self.setupMarker(self.currentUsertMarker, With: downloadImage)
                    }
                })
            }).resume()
        }
        zoomOutToCurrentUser()
    }
    
    func setupMarker(_ userMarker: GMSMarker, With image:UIImage) {
        let userPinImg : UIImage = UIImage(named: "markerImage")!
        UIGraphicsBeginImageContextWithOptions(userPinImg.size, false, 0.0);
        
        userPinImg.draw(in: CGRect(origin: .zero, size: userPinImg.size))
        
        let roundRect : CGRect = CGRect(x: 12.5, y: 13, width: userPinImg.size.width-25, height: userPinImg.size.width-25)
        
        let myUserImgView = UIImageView(frame: roundRect)
        myUserImgView.image = nil
       // myUserImgView.image = UIImage(named: "face")
        myUserImgView.image = image
        let layer: CALayer = myUserImgView.layer
        
        layer.masksToBounds = true
        layer.cornerRadius = myUserImgView.frame.size.width/2
        
        UIGraphicsBeginImageContextWithOptions(myUserImgView.bounds.size, myUserImgView.isOpaque, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        roundedImage?.draw(in: roundRect)
        
        
        let resultImg : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        userMarker.iconView = nil
        userMarker.iconView = UIImageView(image: resultImg)
        userMarker.map = self.mapView
    }
    
    func customizeEventParticipantsMarkers() {
        if !(markerDict.isEmpty) {
            //            for markerDictionary in markerDict {
            //                let marker = markerDictionary.value
            //                marker.map = nil
            //            }
            mapView.clear()
        }
        
        for loggedInUser in userList {
            let user_marker = GMSMarker()
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            user_marker.position = loggedInUser.location
            user_marker.title = loggedInUser.name
            user_marker.snippet = "MobileNo: \(loggedInUser.phoneNumber)"
            
            if !(TeamTracker.validateUrl(urlString: loggedInUser.avatar)) {
                self.setupMarker(user_marker, With: UIImage(named: "DefaultMarkerIcon")!)
                markerDict[loggedInUser.name] = user_marker
                continue
            }
            let imageURL = URL(string: loggedInUser.avatar)
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                if let err = error{
                    print(err.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        self.alert(title: "Error", msg: "\(err.localizedDescription)")
                    })
                    return
                }
                DispatchQueue.main.async(execute: {
                    if let downloadImage = UIImage(data: data!){
                        self.setupMarker(user_marker, With: downloadImage)
                    }
                })
            }).resume()
            CATransaction.commit()
            markerDict[loggedInUser.name] = user_marker
        }
        zoomOutToCurrentUser()
    }
    
    func zoomOutToCurrentUser(){
        CATransaction.begin()
        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        mapView.animate(to: GMSCameraPosition.camera(withTarget: currentUser.location, zoom: 8))
        CATransaction.commit()
    }
    
    func setupMapview(){
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: footerView.topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func setupNavigationBar(){
        self.title = currentUser.mission
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.init(r: 255, g: 177, b: 0)
        
        // create the button
        let suggestImage  = UIImage(named: "Share")!.withRenderingMode(.alwaysOriginal)
        let suggestButton = UIButton(frame: CGRect(x: 0,y: 0,width: 32,height: 32))
        suggestButton.setBackgroundImage(suggestImage, for: .normal)
        suggestButton.addTarget(self, action: #selector(TeamTrackingController.handleShare), for:.touchUpInside)
        
        // here where the magic happens, you can shift it where you like
        suggestButton.transform = CGAffineTransform(translationX: 6, y: 0)
        
        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: suggestButton.frame)
        suggestButtonContainer.addSubview(suggestButton)
        let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
        
        // add button shift to the side
        navigationItem.rightBarButtonItem = suggestButtonItem
    }
    
    @objc func handleShare() {
        let shareActionSheet = UIAlertController(title: nil, message: "Share With", preferredStyle: .actionSheet)
        let twitterShareAction = UIAlertAction(title: "Twitter", style: .default) { (action) in
            //Display the twitter composer
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                let tweetComposer = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                tweetComposer?.setInitialText("https://teamtracker.riverway.in")
                tweetComposer?.add(UIImage(named: "title_icon"))
                self.present(tweetComposer!, animated: true, completion: nil)
            }else{
                self.alert(title: "Twitter unavailable", msg:"Be sure to go to Settings>Twitter to set up your Twitter account")
            }
        }
        
        let faceBookShareAction = UIAlertAction(title: "FaceBook", style: .default) { (action) in
            //Display the facebook composer
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                let faceBookComposer = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                faceBookComposer?.setInitialText("https://teamtracker.riverway.in")
                faceBookComposer?.add(UIImage(named: "title_icon"))
                self.present(faceBookComposer!, animated: true, completion: nil)
            }else{
                self.alert(title: "FaceBook unavailable", msg:"Be sure to go to Settings>FaceBook to set up your Facebook account")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        shareActionSheet.addAction(twitterShareAction)
        shareActionSheet.addAction(faceBookShareAction)
        shareActionSheet.addAction(cancelAction)
        self.present(shareActionSheet, animated: true, completion: nil)
    }
   
    func alert(title: String, msg: String){
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
   
    func customizeFooterView(){
        //need x, y, width, height constraints
        footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        footerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let copyRightLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont(name: "HelveticaNeue", size: CGFloat(14))
            label.textColor = .white
            label.text = "Copyright © RiverWay Inc. All rights reserved."
            label.translatesAutoresizingMaskIntoConstraints = false
            
            return label
        }()
        
        footerView.addSubview(copyRightLabel)
        //need x, y, width, height constraints
        copyRightLabel.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 12).isActive = true
        copyRightLabel.trailingAnchor.constraint(equalTo: footerView.trailingAnchor).isActive = true
        copyRightLabel.centerYAnchor.constraint(equalTo: footerView.centerYAnchor).isActive = true
        copyRightLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    @objc func handleLogout() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupLocationManager(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        let latitude = userLocation!.coordinate.latitude
        let longitude = userLocation!.coordinate.longitude
        let currentLocation = CLLocationCoordinate2DMake(latitude, longitude)
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        currentUsertMarker.position = currentLocation
        currentUsertMarker.map = mapView
        CATransaction.commit()
        
        location = ["lat": latitude,
                    "lng": longitude]
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(emitCurrentLocation), userInfo: nil, repeats: false)
    }
    
    @objc func emitCurrentLocation(){
        SocketIOManager.sharedInstance.updateLocation(pSeudoName: self.currentUser.pSeudoName,newLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

