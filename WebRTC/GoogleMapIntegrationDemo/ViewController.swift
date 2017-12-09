

//  ViewController.swift
//  GoogleMapIntegrationDemo
//
//  Created by Shaik on 20/10/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

import UIKit
import GoogleMaps
//import GooglePlaces
//import GoogleMapsCore

class User: NSObject {
    let name: String
    var location: CLLocationCoordinate2D
    let infoWindow: CustomInfoView
    
    init(name: String, location: CLLocationCoordinate2D, infoWindow: CustomInfoView) {
        self.name = name
        self.infoWindow = infoWindow
        self.infoWindow.pSuedoName = name
        
        self.location = location
    }
}

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    var roomName: String!
    var client: ARDAppClient?
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?

    
    
    var mapView: GMSMapView?
    
    var locationManager = CLLocationManager()
    
    var markerDict: [String: GMSMarker] = [:]
    
    
    var currentUserMarker = GMSMarker()
    var currentUserInfoWindow = CustomInfoView()
    var users = [User]()
    
    // MARK: Needed to create the custom info window
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUserMarker.title = "Nanni"
        currentUserInfoWindow.pSuedoName = "Nanni"
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.removeInfoWindowMarkerFromSelectedMarkers(notification:)),
                                               name: Notification.Name("InfoWindowNotification1"),
                                               object: nil)
    
        let image = UIImage(named: "India-Flag")
        if let profileImageData = UIImagePNGRepresentation(image!){
            //  let profileImageDataString = String(data: profileImageData, encoding: .utf8)
            let profileImageDataString = profileImageData.base64EncodedString(options: [])
            
            let dataDecoded:NSData = NSData(base64Encoded: profileImageDataString, options: NSData.Base64DecodingOptions(rawValue: 0))!
            //    imageView2.image = UIImage(data: dataDecoded as Data)!
            
            users =  [User(name: "Subhani", location: CLLocationCoordinate2DMake(37.792905, -122.397059), infoWindow: CustomInfoView()), User(name: "Srikant", location: CLLocationCoordinate2DMake(37.795434, -122.39473), infoWindow: CustomInfoView()), User(name: "Suresh", location: CLLocationCoordinate2DMake(37.802378, -122.405811), infoWindow: CustomInfoView()), User(name: "Bhasha", location: CLLocationCoordinate2DMake(37.808, -122.417743), infoWindow: CustomInfoView()), User(name: "Gouse Rabbani", location: CLLocationCoordinate2DMake(37.807664, -122.475069), infoWindow: CustomInfoView())]
        }
        GMSServices.provideAPIKey("AIzaSyDzgSjuctiaOLdu41j_OJBI3USyUbYomjU")
        let camera = GMSCameraPosition.camera(withLatitude: 37.792905, longitude: -122.397059, zoom: 11)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //view = mapView
        view.addSubview(mapView!)
        mapView?.translatesAutoresizingMaskIntoConstraints = false
        
        mapView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        mapView?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        mapView?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        
        for user in users {
            let user_marker = GMSMarker()
            user_marker.position = user.location
            user_marker.title = user.name
            // user_marker.snippet = "Hey, this is \(user.name)"
            user_marker.map = mapView
            
            user_marker.iconView = setMarker(image: UIImage(named: "title_icon")!)
            markerDict[user.name] = user_marker
            
            //  markerDict[user.name] =
        }
        fitAllMarkers()
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = self
        locationManager.delegate = self
        //iOS has a simple way to request a user's location just once, and it's called requestLocation()
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        /* Notify changes when device has moved x meters.
         * Default value is kCLDistanceFilterNone: all movements are reported.
         didUpdateLocation() called every 10Metre*/
        //  self.locationManager.distanceFilter = 10.0 // you can change as per your require ment
        locationManager.startUpdatingLocation()
        Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateMarkers), userInfo: nil, repeats: true)
    }
   
    
    //WebRTC Implementation
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // disconnect()
    }
    
    
    
   
    //    MARK: Private
    func showAlertWithMessage(_ message: String){
        let alertView: UIAlertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alertView.addAction(alertAction)
        self.present(alertView, animated: true, completion: nil)
    }
    
    
    
    //Creating Bound for showing all markers
    func fitAllMarkers(){
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate(currentUserMarker.position)
        for user in users {
            guard let user_marker = markerDict[user.name] else { return }
            bounds = bounds.includingCoordinate(user_marker.position)
        }
        let update = GMSCameraUpdate.fit(bounds, withPadding: 30)
        mapView?.animate(with: update)
    }
    
    var lat: Double = 0.01
    var long: Double = 0.01
    
    @objc func updateMarkers() {
        for user in users {
            guard let user_marker = markerDict[user.name] else { return }
            user.location.latitude -= lat
            user.location.longitude += long
            CATransaction.begin()
            user_marker.position = user.location
            user_marker.title = user.name
    //        mapView?.animate(to: GMSCameraPosition.camera(withTarget: currentUserMarker.position, zoom: (mapView?.camera.zoom)!))
            mapView?.animate(to: GMSCameraPosition.camera(withTarget: centerMapCoordinate, zoom: (mapView?.camera.zoom)!))
            // user_marker.snippet = "Hey, this is \(user.name)"
            user_marker.map = mapView
            
            user_marker.iconView = setMarker(image: UIImage(named: "compose")!)
            CATransaction.commit()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let userLocation = locations.last
        let currentLocation = CLLocationCoordinate2DMake(userLocation!.coordinate.latitude, userLocation!.coordinate.longitude)
        CATransaction.begin()
//        if let centerMap = centerMapCoordinate{
//            mapView?.animate(to: GMSCameraPosition.camera(withTarget: centerMap, zoom: (mapView?.camera.zoom)!))
//        }
        currentUserMarker.position = currentLocation
        CATransaction.commit()
        currentUserMarker.map = mapView
        mapView?.isMyLocationEnabled = true
    }
    
    
    
    func setMarker(image:UIImage) -> UIImageView{
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.image = image
        return imageView
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return UIView()
    }
    
    // Needed to create the custom info window
    var selectedMarkers = [GMSMarker]()
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        // Placing Marker refference into selectedMarkers array
        var flag = 0
        if selectedMarkers.isEmpty {
            selectedMarkers.append(marker)
        }else{
            for selectedMarker in selectedMarkers{
                if marker.title == selectedMarker.title{
                    flag = 1
                    break
                }
            }
            if flag == 0 {
                selectedMarkers.append(marker)
            }
        }
        // Hidding selectedMarkers
        for selectedMarker in selectedMarkers{
            if selectedMarker.title == "Nanni" {
                self.currentUserInfoWindow.isHidden = true
            }else{
                for user in users {
                    if user.name == selectedMarker.title {
                        user.infoWindow.isHidden = true
                        break
                    }
                }
            }
        }
        // Pumping user details of selectedMarker into respected infowindow
        let markerName = marker.title!
        if markerName == "Nanni" {
            self.currentUserInfoWindow.removeFromSuperview()
            self.view.addSubview(self.currentUserInfoWindow)
            
            self.currentUserInfoWindow.center = mapView.projection.point(for: marker.position)
            self.currentUserInfoWindow.center.y = self.currentUserInfoWindow.center.y - 82
            
            
            self.currentUserInfoWindow.name.text = markerName
            self.currentUserInfoWindow.email.text = "Its4Nanni@gmail.com"
            self.currentUserInfoWindow.phoneNo.text = "9550420789"
        }else{
            for user in users {
                if user.name == markerName {
                    user.infoWindow.removeFromSuperview()
                    self.view.addSubview(user.infoWindow)
    
                    user.infoWindow.center = mapView.projection.point(for: marker.position)
                    user.infoWindow.center.y = user.infoWindow.center.y - 82
                    
                    user.infoWindow.name.text = user.name
                    user.infoWindow.email.text = "Its4Bhasha@gmail.com"
                    user.infoWindow.phoneNo.text = "7013822249"
                    
                    break
                }
            }
        }
        mapView.animate(to: GMSCameraPosition.camera(withTarget: centerMapCoordinate, zoom: mapView.camera.zoom))
        return false
    }
    
    var centerMapCoordinate:CLLocationCoordinate2D!
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        let latitude = mapView.camera.target.latitude - 0.000001
        let longitude = mapView.camera.target.longitude
        centerMapCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        //    CATransaction.begin()
        for selectedMarker in selectedMarkers{
            let markerName = selectedMarker.title!
            if markerName == "Nanni"{
                currentUserInfoWindow.center = mapView.projection.point(for: selectedMarker.position)
                currentUserInfoWindow.center.y = currentUserInfoWindow.center.y - 82
                //currentUserInfoWindow.isHidden = false
            }else{
                for user in users {
                    if markerName == user.name {
                        user.infoWindow.center = mapView.projection.point(for: selectedMarker.position)
                        user.infoWindow.center.y = user.infoWindow.center.y - 82
                        //user.infoWindow.isHidden = false
                    }
                }
            }
        }
        for selectedMarker in selectedMarkers{
            if selectedMarker.title == "Nanni" {
                self.currentUserInfoWindow.isHidden = false
            }else{
                for user in users {
                    if user.name == selectedMarker.title {
                        user.infoWindow.isHidden = false
                        break
                    }
                }
            }
        }
        //  CATransaction.commit()
    }
    
    //   MARK: Needed to create the custom info window
//    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//        // Removing selectedMarker's Infowindows
//        for selectedMarker in selectedMarkers{
//            if selectedMarker.title == "Nanni" {
//                self.currentUserInfoWindow.removeFromSuperview()
//            }else{
//                for user in users {
//                    if user.name == selectedMarker.title {
//                        user.infoWindow.removeFromSuperview()
//                        break
//                    }
//                }
//            }
//        }
//
//    }
    
    @objc func removeInfoWindowMarkerFromSelectedMarkers(notification: Notification){
        var infowindowMarkerPosition: CLLocationCoordinate2D = CLLocationCoordinate2D()
        if let infoWindowName = notification.userInfo?["InfoWindowName"] as? String {
            for selectedMarker in selectedMarkers{
                if selectedMarker.title == infoWindowName {
                    infowindowMarkerPosition = selectedMarker.position
                    infowindowMarkerPosition.latitude += 0.000001
                    selectedMarkers = selectedMarkers.filter{$0 != selectedMarker}
                    break
                }
            }
        }
        // Hidding selectedMarkers
        for selectedMarker in selectedMarkers{
            if selectedMarker.title == "Nanni" {
                self.currentUserInfoWindow.isHidden = true
            }else{
                for user in users {
                    if user.name == selectedMarker.title {
                        user.infoWindow.isHidden = true
                        break
                    }
                }
                mapView?.animate(to: GMSCameraPosition.camera(withTarget: infowindowMarkerPosition, zoom: (mapView?.camera.zoom)!))
            }
        }
    }
}

