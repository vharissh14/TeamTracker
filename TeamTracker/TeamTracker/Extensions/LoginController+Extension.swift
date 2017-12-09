//
//  LoginController+Extension.swift
//  TeamTracker
//
//  Created by Shaik on 15/11/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

import UIKit
import FBSDKLoginKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

extension LoginController: UITextFieldDelegate, GIDSignInUIDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, TeamImageProtocol, newTeamImageProtocol, GIDSignInDelegate {
    
    func setupArchitectView(){
        let architectView = UIView(frame: self.view.bounds)
        self.view.addSubview(architectView)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        gestureRecognizer.delegate = self
        architectView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.teamNameTextField.dismissDropDown()
            self.view.endEditing(true)
        }, completion: nil)
    }
    
    func customizeNavBar(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "Arial", size: 20)!]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.title = "TeamTracker"
    }
    
    func setupFacebookButton(){
        //need x, y, width, height constraints
        facebookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookButton.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 8).isActive = true
        facebookButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        facebookButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupGoogleButton(){
        //need x, y, width, height constraints
        googleButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleButton.topAnchor.constraint(equalTo: facebookButton.bottomAnchor, constant: 8).isActive = true
        googleButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        googleButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func alert(title: String, msg: String){
        myActivityIndicator.stopAnimating()
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        }))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result,err) in
            if let err = err {
                print("Custom FB LogIn failed: ", err)
                return
            }
            
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id, name, last_name, email"]).start { (connection, result, err) in
                if err != nil {
                        print("Failed to start graph request:", err ?? "")
                        return
                }
                
                guard let facebookUser = result as? [String:Any] else { return }
                print(facebookUser)
                
                if let name = facebookUser["name"] {
                    self.nameTextField.text = name as? String
                }
                
                if let lastName = facebookUser["last_name"] {
                    self.pSeudoNameTextField.text = lastName as? String
                }
                
                if let email = facebookUser["email"] {
                    self.emailTextField.text = email as? String
                }
    
                
                self.loginRegisterSegmentedControl.selectedSegmentIndex = 1
                self.handleLoginRegisterChange()
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("Failed to log into Google: ",err)
            return
        }
        
        print("Successfully logged into Google")
        print("User Id: \(user.userID!)")
        
        print("User Name: \(user.profile.name!)")
        print("Email: \(user.profile.email!)")
        
        if let name = user.profile.name {
            self.nameTextField.text = name
            self.pSeudoNameTextField.text = name
        }
        
        if let email = user.profile.email {
            self.emailTextField.text = email
        }
        self.loginRegisterSegmentedControl.selectedSegmentIndex = 1
        self.handleLoginRegisterChange()
    }
    
    @objc func handleCustomGoogleLogin() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc func handleLoginRegisterChange() {
       
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: UIControlState())
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }, completion: nil)
        teamNameTextField.dismissDropDown()
        view.endEditing(true)
        
        inputsContainerViewCenterYAnchor?.isActive = false
        inputsContainerViewCenterYAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 1 ? 110 : 55
        inputsContainerViewCenterYAnchor?.isActive = true
        inputsContainerViewBottomAnchor?.isActive = false
        inputsContainerViewBottomAnchor = inputsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        
        facebookButton.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 1
        googleButton.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 1
        
        newTeamImageView.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        // change height of inputContainerView, but how???
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 140 : 250
        
        // change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/6)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        teamNameTextFieldHeightAnchor?.isActive = false
        teamNameTextFieldHeightAnchor = teamNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/6)
        teamNameTextFieldHeightAnchor?.isActive = true
        teamNameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        teamNameSeparatorView.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        pSeudoNameTextFieldHeightAnchor?.isActive = false
        pSeudoNameTextFieldHeightAnchor = pSeudoNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/3 : 1/6)
        pSeudoNameTextFieldHeightAnchor?.isActive = true
        
        missionNameTextFieldHeightAnchor?.isActive = false
        missionNameTextFieldHeightAnchor = missionNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/3 : 0)
        missionNameTextFieldHeightAnchor?.isActive = true
        missionNameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 1
        
        phoneNumberTextFieldHeightAnchor?.isActive = false
        phoneNumberTextFieldHeightAnchor = phoneNumberTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/6)
        phoneNumberTextFieldHeightAnchor?.isActive = true
        phoneNumberTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/6)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/3 : 1/6)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func setupProfileImageView() {
        //need x, y, width, height constraints
        if UIDevice.current.modelName == "iPhone 5s" || UIDevice.current.modelName == "iPhone 5c" || UIDevice.current.modelName == "iPhone 5" || UIDevice.current.modelName == "iPhone 4s" || UIDevice.current.modelName == "iPhone 4"{
            profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -8).isActive = true
        }else{
            profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -45).isActive = true
        }
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupLoginRegisterSegmentedControl() {
        //need x, y, width, height constraints
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -8).isActive = true
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, multiplier: 1).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupInputsContainerView() {
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerViewCenterYAnchor?.isActive = false
        inputsContainerViewCenterYAnchor = inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 110)
        inputsContainerViewCenterYAnchor?.isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 250)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerViewBottomAnchor?.isActive = false
        inputsContainerViewBottomAnchor = inputsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeparatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeparatorView)
        inputsContainerView.addSubview(phoneNumberTextField)
        inputsContainerView.addSubview(phoneNumberSeparatorView)
        inputsContainerView.addSubview(pSeudoNameTextField)
        inputsContainerView.addSubview(pSeudoNameSeparatorView)
        
        view.addSubview(teamNameTextField)
        view.addSubview(newTeamImageView)
        inputsContainerView.addSubview(teamNameSeparatorView)
        inputsContainerView.addSubview(missionNameTextField)
        inputsContainerView.addSubview(missionNameSeparatorView)
        inputsContainerView.addSubview(passwordTextField)
        
        //need x, y, width, height constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/6)
        nameTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        nameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeparatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/6)
        emailTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        phoneNumberTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        phoneNumberTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        
        phoneNumberTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        phoneNumberTextFieldHeightAnchor = phoneNumberTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/6)
        phoneNumberTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        phoneNumberSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        phoneNumberSeparatorView.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor).isActive = true
        phoneNumberSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        phoneNumberSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        
        pSeudoNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        pSeudoNameTextField.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor).isActive = true
        pSeudoNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        pSeudoNameTextFieldHeightAnchor = pSeudoNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/6)
        
        pSeudoNameTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        pSeudoNameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        pSeudoNameSeparatorView.topAnchor.constraint(equalTo: pSeudoNameTextField.bottomAnchor).isActive = true
        pSeudoNameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        pSeudoNameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        
        missionNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        missionNameTextField.topAnchor.constraint(equalTo: pSeudoNameTextField.bottomAnchor).isActive = true
        missionNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        
        missionNameTextFieldHeightAnchor = missionNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/6)
        missionNameTextFieldHeightAnchor?.isActive = true
        
        //need x, y, width, height constraints
        missionNameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        missionNameSeparatorView.topAnchor.constraint(equalTo: missionNameTextField.bottomAnchor).isActive = true
        missionNameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        missionNameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        
        teamNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        teamNameTextField.topAnchor.constraint(equalTo: missionNameSeparatorView.bottomAnchor).isActive = true
        teamNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor, constant: -58).isActive = true
        teamNameTextFieldHeightAnchor = teamNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/6)
        
        teamNameTextFieldHeightAnchor?.isActive = true
        
        newTeamImageView.leadingAnchor.constraint(equalTo: teamNameTextField.trailingAnchor, constant: 8).isActive = true
        newTeamImageView.topAnchor.constraint(equalTo: teamNameTextField.topAnchor, constant: 2).isActive = true
        newTeamImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        newTeamImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //need x, y, width, height constraints
        teamNameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        teamNameSeparatorView.topAnchor.constraint(equalTo: teamNameTextField.bottomAnchor).isActive = true
        teamNameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        teamNameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        //need x, y, width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: teamNameTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/6)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    func setupLoginRegisterButton() {
        //need x, y, width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 8).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupActivityIndicator() {
        //need x, y, width, height constraints
        activityIndicatorCenterXAnchor = myActivityIndicator.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 0)
        activityIndicatorCenterXAnchor?.isActive = true
        activityIndicatorCenterYAnchor = myActivityIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
        activityIndicatorCenterYAnchor?.isActive = true
        myActivityIndicator.widthAnchor.constraint(equalToConstant: 36).isActive = true
        myActivityIndicator.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func handleLoginRegister() {
        myActivityIndicator.startAnimating()
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        view.endEditing(true)
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            if !isValid(pSeudoNameTextField.text){
                alert(title: "Error", msg: "Please Enter pSeudoName")
            }else if !isValid(missionNameTextField.text){
                alert(title: "Error", msg: "Please Enter Event Name")
            }else if !isValid(passwordTextField.text){
                alert(title: "Error", msg: "Please Enter Valid Password(<= 10 Alphabets)")
            }else{
                handleLogin()
            }
        } else {
            if !isValid(nameTextField.text){
                alert(title: "Error", msg: "Please Enter Name")
            }else if !validateEmail(emailTextField.text){
                alert(title: "Error", msg: "Please Enter Valid EmailID")
            }else if !validatePhoneNumber(phoneNumberTextField.text){
                alert(title: "Error", msg: "Please Valid Phone Number")
            }else if !isValid(pSeudoNameTextField.text){
                alert(title: "Error", msg: "Please Enter pSeudoName")
            }else if !isValid(teamNameTextField.text){
                alert(title: "Error", msg: "Please Select TeamName")
            }else if !isValid(passwordTextField.text){
                alert(title: "Error", msg: "Please Enter Valid Password(<= 10 Alphabets)")
            }else{
                handleRegister()
            }
        }
    }
   
    func isValid(_ text: String!) -> Bool {
        if text.isEmpty || text == " "{
            return false
        }
        return true
    }
    
    func validateEmail(_ enteredEmail: String!) -> Bool{
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    func validatePhoneNumber(_ value: String!) -> Bool {
        if value.count <= 9 {
            return false
        }
        return true
    }
   
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool  {
        if textField.tag == 102 || textField.tag == 105 {
            let currentCharacterCount = textField.text?.count ?? 0
            if (range.length + range.location > currentCharacterCount){
                return false
            }
            let newLength = currentCharacterCount + string.count - range.length
            return newLength <= 10
        }else{
            return true
        }
    }
    
    func handleLogin() {
        activityIndicatorCenterXAnchor?.isActive = false
        activityIndicatorCenterXAnchor = myActivityIndicator.centerXAnchor.constraint(equalTo: loginRegisterButton.centerXAnchor, constant: 60)
        activityIndicatorCenterXAnchor?.isActive = true
        
        activityIndicatorCenterYAnchor?.isActive = false
        activityIndicatorCenterYAnchor = myActivityIndicator.centerYAnchor.constraint(equalTo: loginRegisterButton.centerYAnchor, constant: 0)
        activityIndicatorCenterYAnchor?.isActive = true
        
        myActivityIndicator.startAnimating()
        
        guard let pSeudoName = pSeudoNameTextField.text, let password = passwordTextField.text, let mission = missionNameTextField.text else {
            print("Form is not valid")
            return
        }
        
        let logInUser: [String: String] = [ "pseudoName": pSeudoName,
                                            "mission": mission,
                                            "password": password ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: logInUser)
        // create post request
        let url = URL(string: "\(TeamTracker.serverHostUrl)/api/users/authenticate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI1OWVkY2Y1OGMyNGFiMzBmMTBhNmZhYjciLCJpYXQiOjE1MDk0NDQ1MTR9.MkV450FGKxfA2E4pS1dIoKbfGQIzPN3jdnakaQWCvnc", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // insert json data to the request
        request.httpBody = jsonData
        //   let session = URLSession.shared
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let err = error {
                print(err.localizedDescription)
                DispatchQueue.main.async(execute: {
                    self.alert(title: "Error", msg: "\(err.localizedDescription)")
                })
                return
            }
            guard let data = data else { return }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] else { return }
                
                let url = URL(string: "\(TeamTracker.serverHostUrl)/api/users/current")!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let token = "Bearer \(json["token"] as! String)"
                request.addValue(token, forHTTPHeaderField: "Authorization")
                URLSession.shared.dataTask(with: request) { data, response, error in
                    if let err = error {
                        print(err.localizedDescription)
                        DispatchQueue.main.async(execute: {
                            self.alert(title: "Error", msg: "\(err.localizedDescription)")
                        })
                        return
                    }
                  
                    guard let data = data else { return }
                    do{
                        guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any] else { return }
                        DispatchQueue.main.async(execute: {
                            let loggedInUser = User(user: json)
                            loggedInUser.mission = mission
                            self.presentTeamTracker(loggedInUser)
                        })
                        
                    }catch let jsonErr{
                        print("Error serializing json: ", jsonErr)
                        DispatchQueue.main.async(execute: {
                            self.alert(title: "Error", msg: "\(jsonErr.localizedDescription)")
                        })
                    }
                    }.resume()
            }catch let jsonErr {
                print("Error serializing json: ", jsonErr)
                 DispatchQueue.main.async(execute: {
                    self.alert(title: "Error", msg: "Wrong User Details")
                })
            }
        }.resume()
    }
    
    func handleRegister() {
        activityIndicatorCenterXAnchor?.isActive = false
        activityIndicatorCenterXAnchor = myActivityIndicator.centerXAnchor.constraint(equalTo: loginRegisterButton.centerXAnchor, constant: 60)
        activityIndicatorCenterXAnchor?.isActive = true
        
        activityIndicatorCenterYAnchor?.isActive = false
        activityIndicatorCenterYAnchor = myActivityIndicator.centerYAnchor.constraint(equalTo: loginRegisterButton.centerYAnchor, constant: 0)
        activityIndicatorCenterYAnchor?.isActive = true
        
        myActivityIndicator.startAnimating()
        
        guard let pSeudoName = pSeudoNameTextField.text, let phoneNumber = phoneNumberTextField.text, let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text, let teamName = teamNameTextField.text else {
            print("Form is not valid")
            return
        }
        
        let avatar = selectedImageUrl
        currentUser = pSeudoName
        
        let newUser: [String: String] = [   "name": name,
                                            "teamIcon": avatar,
                                            "phone": phoneNumber,
                                            "email": email,
                                            "pseudoName": pSeudoName,
                                            "teams": teamName,
                                            "password": password ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: newUser)
        // create post request
        let url = URL(string: "\(TeamTracker.serverHostUrl)/api/users/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiI1OWVkY2Y1OGMyNGFiMzBmMTBhNmZhYjciLCJpYXQiOjE1MDk0NDQ1MTR9.MkV450FGKxfA2E4pS1dIoKbfGQIzPN3jdnakaQWCvnc", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // insert json data to the request
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let err = error {
                print(err.localizedDescription)
                DispatchQueue.main.async(execute: {
                    self.alert(title: "Error", msg: "\(err.localizedDescription)")
                })
                return
            }
            if let httpResponse = response as? HTTPURLResponse{
                if httpResponse.statusCode == 400{
                    self.alert(title: "", msg: "User Already Exist")
                    return
                }
            }
            DispatchQueue.main.async(execute: {
                self.alert(title: "", msg: "User Successfully Registered")
                self.loginRegisterSegmentedControl.selectedSegmentIndex = 0
                self.myActivityIndicator.stopAnimating()
                self.handleLoginRegisterChange()
            })
        }.resume()
    }
    
    func presentTeamTracker(_ loggedInuser: User) {
        let teamTrackerVC = TeamTrackingController()
        teamTrackerVC.currentUser = loggedInuser
        myActivityIndicator.stopAnimating()
        let navController = UINavigationController(rootViewController: teamTrackerVC)
        present(navController, animated: true, completion: nil)
    }

    @objc func handleNewTeam() {
        teamNameTextField.text = ""
        teamNameTextField.dismissDropDown()
        profileImageView.image = UIImage(named: "user_male_circle")
        let newTeamViewController = NewTeamViewController()
        newTeamViewController.newTeamDelegate = self
        let navController = UINavigationController(rootViewController: newTeamViewController)
        self.present(navController, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            textField.resignFirstResponder()
        }, completion: nil)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 104 {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.getTeamNames()
                self.view.endEditing(true)
                textField.resignFirstResponder()
            }, completion: nil)
            return false
        }
        teamNameTextField.dismissDropDown()
        return true
    }
    
    func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        let keyboardFrame = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (sender.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        inputsContainerViewCenterYAnchor?.isActive = false
        inputsContainerViewBottomAnchor?.isActive = true
        if UIDevice.current.modelName == "iPhone 5s" || UIDevice.current.modelName == "iPhone 5c" || UIDevice.current.modelName == "iPhone 5" || UIDevice.current.modelName == "iPhone 4s" || UIDevice.current.modelName == "iPhone 4"{
            inputsContainerViewBottomAnchor?.constant = -keyboardFrame!.height
        }else{
            inputsContainerViewBottomAnchor?.constant = -(keyboardFrame!.height + loginRegisterButton.frame.height + 10)
        }
        
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        let keyboardDuration = (sender.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        inputsContainerViewCenterYAnchor?.isActive = true
        inputsContainerViewBottomAnchor?.isActive = false
        inputsContainerViewBottomAnchor?.constant = view.frame.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func  getTeamNames() {
        let teamNamesURL = URL(string: "\(TeamTracker.serverHostUrl)/api/users/team")
        var request = URLRequest(url: teamNamesURL!)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let err = error{
                print(err.localizedDescription)
                DispatchQueue.main.async(execute: {
                    self.alert(title: "Error", msg: "\(err.localizedDescription)")
                })
                return
            }
            do{
                guard let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [[String:AnyObject]] else { return }
                self.teamlist = json
                DispatchQueue.main.async(execute: {
                    self.teamNameTextField.dropView.dropDownOptions.removeAll()
                    for team in json {
                        guard let teamName = team["teamName"] else { continue }
                        //    self.teamNames?.append(teamName as! String)
                        self.teamNameTextField.dropView.dropDownOptions.append(teamName as! String)
                        self.teamNameTextField.dropView.tableView.reloadData()
                    }
                })
            }catch let jsonErr{
                print("Error serializing json: ", jsonErr)
                DispatchQueue.main.async(execute: {
                    self.alert(title: "Error", msg: "\(jsonErr.localizedDescription)")
                })
            }
        }).resume()
    }
    
    func setTeamImage(teamName : String) {
        activityIndicatorCenterXAnchor?.isActive = false
        activityIndicatorCenterXAnchor = myActivityIndicator.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 0)
        activityIndicatorCenterXAnchor?.isActive = true
        
        activityIndicatorCenterYAnchor?.isActive = false
        activityIndicatorCenterYAnchor = myActivityIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 0)
        activityIndicatorCenterYAnchor?.isActive = true

        self.myActivityIndicator.startAnimating()
        for team in teamlist {
            guard let tName = team["teamName"] else { return }
            if tName as? String == teamName{
                guard let teamIconURL = team["teamIcon"] else { return }
                selectedImageUrl = teamIconURL as! String
                if !(TeamTracker.validateUrl(urlString: selectedImageUrl)) {
                    self.profileImageView.image = UIImage(named: "DefaultMarkerIcon")
                    self.myActivityIndicator.stopAnimating()
                }else {
                    let imageURL = URL(string: selectedImageUrl)
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
                                self.profileImageView.image = downloadImage
                                self.view.layoutIfNeeded()
                                self.myActivityIndicator.stopAnimating()
                            }
                        })
                    }).resume()
                }
                break
            }
        }
    }
  
    func selectedImageUrl(imageName : String, imageUrl: String) {
        activityIndicatorCenterXAnchor?.isActive = false
        activityIndicatorCenterXAnchor = myActivityIndicator.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor, constant: 0)
        activityIndicatorCenterXAnchor?.isActive = true
        
        activityIndicatorCenterYAnchor?.isActive = false
        activityIndicatorCenterYAnchor = myActivityIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor, constant: 0)
        activityIndicatorCenterYAnchor?.isActive = true
        
        self.myActivityIndicator.startAnimating()
        
        selectedImageUrl = imageUrl
        teamNameTextField.text = imageName
        if !(TeamTracker.validateUrl(urlString: imageUrl)) {
            self.profileImageView.image = UIImage(named: "DefaultMarkerIcon")
            self.myActivityIndicator.stopAnimating()
        }else {
            let imgURL = URL(string: imageUrl)
            URLSession.shared.dataTask(with: imgURL!, completionHandler: { (data, response, error) in
                if let err = error{
                    print(err.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        self.alert(title: "Error", msg: "\(err.localizedDescription)")
                    })
                    return
                }
                DispatchQueue.main.async(execute: {
                    if let downloadImage = UIImage(data: data!){
                        self.profileImageView.image = downloadImage
                        self.myActivityIndicator.stopAnimating()
                    }
                })
            }).resume()
        }
    }
}

