//
//  CustomInfoView.swift
//  GoogleMapIntegrationDemo
//
//  Created by Shaik on 26/10/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

//
//  CustomInfoView.swift
//  TeamTracker
//
//  Created by Shaik on 26/10/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

import UIKit

class CustomInfoView: UIView, ARDAppClientDelegate, RTCEAGLVideoViewDelegate {
    var webRTCDelegate: ViewController!
    
    let videoCallButton: UIButton = {
        let button = UIButton()
        // button.backgroundColor = .gray
        // button.setTitle("Video", for: .normal)
        //  button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        let origImage = UIImage(named: "hangup")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .green
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleVideoCall), for: UIControlEvents.touchUpInside)
        //   button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        //  button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let name: UILabel = {
        let name = UILabel()
        name.font = UIFont.systemFont(ofSize: 16)
        name.textColor = .black
        name.font = name.font.withSize(20)
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    let email: UILabel = {
        let email = UILabel()
        email.font = UIFont.systemFont(ofSize: 14)
        email.textColor = .black
        email.translatesAutoresizingMaskIntoConstraints = false
        return email
    }()
    let phoneNo: UILabel = {
        let phoneNo = UILabel()
        phoneNo.font = UIFont.systemFont(ofSize: 14)
        phoneNo.textColor = .black
        phoneNo.translatesAutoresizingMaskIntoConstraints = false
        return phoneNo
    }()
    
    let closeButton: UIButton = {
        let button = UIButton()
        // button.backgroundColor = .gray
        // button.setTitle("Video", for: .normal)
        //  button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        let origImage = UIImage(named: "closeIcon")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .gray
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(closeInfoWindow), for: UIControlEvents.touchUpInside)
        //   button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        //  button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    let remoteView: RTCEAGLVideoView = {
        let view = RTCEAGLVideoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor(r: 83, g: 83, b: 83)
        view.isHidden = true
        
        return view
    }()
    
    let localView: RTCEAGLVideoView = {
        let view = RTCEAGLVideoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        view.contentMode = .scaleAspectFit
        view.backgroundColor = UIColor(r: 38, g: 38, b: 38)
        
        return view
    }()
    
    let hangupButton: UIButton = {
        let button = UIButton()
        // button.backgroundColor = .gray
        // button.setTitle("Video", for: .normal)
        //  button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        let origImage = UIImage(named: "hangup")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: .normal)
        button.tintColor = .red
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(endVideoCall), for: UIControlEvents.touchUpInside)
        //   button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        //  button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var myActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    var pSuedoName = String()
    
    var roomName: String!
    var client: ARDAppClient?
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let infoViewDimensions = CGSize(width: 220, height: 150)
        self.backgroundColor = .clear
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        let img = UIImage(named: "infowindow_bg")
        self.layer.contents = img?.cgImage
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: infoViewDimensions.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: infoViewDimensions.height).isActive = true
        self.isHidden = true
        
        self.remoteView.delegate = self
        self.roomName = "RiverWay11111"
        
        addSubview(videoCallButton)
        addSubview(name)
        addSubview(email)
        addSubview(phoneNo)
        addSubview(closeButton)
        addSubview(remoteView)
        remoteView.addSubview(localView)
        remoteView.addSubview(hangupButton)
        remoteView.addSubview(myActivityIndicator)
        
        name.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        name.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        name.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        name.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        email.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        email.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 8).isActive = true
        email.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        email.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        phoneNo.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
        phoneNo.topAnchor.constraint(equalTo: email.bottomAnchor, constant: 8).isActive = true
        phoneNo.widthAnchor.constraint(equalToConstant: 120).isActive = true
        phoneNo.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        videoCallButton.leadingAnchor.constraint(equalTo: phoneNo.trailingAnchor).isActive = true
        videoCallButton.topAnchor.constraint(equalTo: email.bottomAnchor, constant: -8).isActive = true
        videoCallButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        videoCallButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -4).isActive = true
        closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        remoteView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5).isActive = true
        remoteView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4).isActive = true
        remoteView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -18).isActive = true
        remoteView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -4).isActive = true
        
        hangupButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        hangupButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        hangupButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        hangupButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        myActivityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        myActivityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        myActivityIndicator.widthAnchor.constraint(equalToConstant: 36).isActive = true
        myActivityIndicator.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    @objc func handleVideoCall(){
        print("Hello")
        myActivityIndicator.startAnimating()
        initialize()
        connectToChatRoom()
        remoteView.isHidden = false
        
        
    }
    
    func initialize(){
        disconnect()
        //        Initializes the ARDAppClient with the delegate assignment
        client = ARDAppClient.init(delegate: self)
        
        //        RTCEAGLVideoViewDelegate provides notifications on video frame dimensions
        //  remoteView.delegate = self
        //  localView.delegate = self
    }
   
    func connectToChatRoom(){
        //client?.serverHostUrl = "https://apprtc.appspot.com"
        client?.serverHostUrl =  "https://appr.tc"
        // client?.serverHostUrl = "https://teamtracker.riverway.in"
        client?.connectToRoom(withId: roomName, options: nil)
    }
    
    //    MARK: RTCEAGLVideoViewDelegate
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        switch state{
        case ARDAppClientState.connected:
            print("Client Connected")
            myActivityIndicator.stopAnimating()
            break
        case ARDAppClientState.connecting:
            print("Client Connecting")
            break
        case ARDAppClientState.disconnected:
            print("Client Disconnected")
            remoteDisconnected()
        }
    }
    
    @objc func endVideoCall(_ sender: UIButton) {
        disconnect()
        //  _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func remoteDisconnected(){
        if(remoteVideoTrack != nil){
            remoteVideoTrack?.remove(remoteView)
        }
        remoteVideoTrack = nil
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        self.localVideoTrack = localVideoTrack
        self.localVideoTrack?.add(localView)
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        self.remoteVideoTrack = remoteVideoTrack
        self.remoteVideoTrack?.add(remoteView)
    }
    
    func appClient(_ client: ARDAppClient!, didError error: Error!) {
        //        Handle the error
        //showAlertWithMessage(error.localizedDescription)
        print(error.localizedDescription)
        disconnect()
    }
    
    func disconnect(){
        if(client != nil){
            if(localVideoTrack != nil){
                localVideoTrack?.remove(localView)
            }
            if(remoteVideoTrack != nil){
                remoteVideoTrack?.remove(remoteView)
            }
            localVideoTrack = nil
            remoteVideoTrack = nil
            client?.disconnect()
            
            remoteView.isHidden = true
            
        }
    }
    
    
    
    //    MARK: RTCEAGLVideoViewDelegate
    
    func videoView(_ videoView: RTCEAGLVideoView!, didChangeVideoSize size: CGSize) {
        //        Resize localView or remoteView based on the size returned
    }
    
    
    
    
    
    @objc func closeInfoWindow(){
        self.removeFromSuperview()
        NotificationCenter.default.post(name: Notification.Name("InfoWindowNotification1"),
                                    object: nil,
                                    userInfo: ["InfoWindowName":self.pSuedoName])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}








