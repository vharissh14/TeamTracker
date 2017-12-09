//
//  NewTeamViewController.swift
//  DropDowning
//
//  Created by Shaik on 08/11/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

import UIKit

class NewTeamViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
      
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "user_male_circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.height/2
        imageView.layer.masksToBounds = false
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var teamNameTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 100
        tf.delegate = self
        tf.placeholder = "Team Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
     
        return tf
    }()
    
    let teamNameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
       
        return view
    }()
    
    lazy var teamIconTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 101
        tf.delegate = self
        tf.placeholder = "Team Url"
        tf.translatesAutoresizingMaskIntoConstraints = false
      
        return tf
    }()
    
    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Submit", for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(UIColor(r: 255, g: 255, b: 255), for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        return button
    }()
   
    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
    }()
    
    var inputsContainerViewCenterYAnchor: NSLayoutConstraint?
    var inputsContainerViewBottomAnchor: NSLayoutConstraint?
    
    var newTeamDelegate : newTeamImageProtocol!
    var appDelegate: AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        self.title = "New Team"
        navigationController?.hidesBarsOnSwipe = false
        setupArchitectView()
        appDelegate = UIApplication.shared.delegate as? AppDelegate

        view.addSubview(profileImageView)
        view.addSubview(inputsContainerView)
        view.addSubview(submitButton)
        view.addSubview(activityIndicator)
        view.bringSubview(toFront: activityIndicator)
        setupProfileImageView()
        setupNavBarButtons()
        setupContainerView()
        setupRegisterButton()
        setupActivityIndicator()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        appDelegate?.statusBarBackgroundView?.isHidden = UIDevice.current.orientation.isLandscape
        observeKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
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
    
    func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        let keyboardFrame = (sender.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let keyboardDuration = (sender.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        inputsContainerViewCenterYAnchor?.isActive = false
        inputsContainerViewBottomAnchor?.isActive = true
        inputsContainerViewBottomAnchor?.constant = -(keyboardFrame!.height + submitButton.frame.height + 10)
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
    
    func setupArchitectView(){
        let architectView = UIView(frame: self.view.bounds)
        self.view.addSubview(architectView)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        gestureRecognizer.delegate = self
        architectView.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc func handleTap(gestureRecognizer: UIGestureRecognizer) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.endEditing(true)
        }, completion: nil)
    }
    
    func setupNavBarButtons(){
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.init(r: 255, g: 177, b: 0)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "View", style: .plain, target: self, action: #selector(handleView))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.init(r: 255, g: 177, b: 0)
    }
    
    func setupRegisterButton() {
        //need x, y, width, height constraints
        submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        submitButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 8).isActive = true
        submitButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        submitButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupActivityIndicator() {
        //need x, y, width, height constraints
        activityIndicator.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 36).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }
    
    func setupContainerView(){
        //need x, y, width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerViewCenterYAnchor?.isActive = false
        inputsContainerViewCenterYAnchor = inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        inputsContainerViewCenterYAnchor?.isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        inputsContainerViewBottomAnchor?.isActive = false
        inputsContainerViewBottomAnchor = inputsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        
        inputsContainerView.addSubview(teamNameTextField)
        inputsContainerView.addSubview(teamNameSeparatorView)
        inputsContainerView.addSubview(teamIconTextField)
        
        teamNameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        teamNameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        teamNameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        teamNameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2).isActive = true
        
        teamNameSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        teamNameSeparatorView.topAnchor.constraint(equalTo: teamNameTextField.bottomAnchor).isActive = true
        teamNameSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        teamNameSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        teamIconTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        teamIconTextField.bottomAnchor.constraint(equalTo: inputsContainerView.bottomAnchor).isActive = true
        teamIconTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        teamIconTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2).isActive = true

    }
    
    func setupProfileImageView() {
        //need x, y, width, height constraints
        if UIDevice.current.modelName == "iPhone 5s" || UIDevice.current.modelName == "iPhone 5c" || UIDevice.current.modelName == "iPhone 5" || UIDevice.current.modelName == "iPhone 4s" || UIDevice.current.modelName == "iPhone 4"{
            profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -8).isActive = true
        }else{
            profileImageView.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -45).isActive = true
        }
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    @objc func handleView() {
        self.view.endEditing(true)
        if teamIconTextField.text == "" {
            alert(title: "Error", msg:"Form is not valid")
            return
        }
        activityIndicator.startAnimating()
        guard let teamIconUrl = teamIconTextField.text else {
            return
        }
        
        if !(TeamTracker.validateUrl(urlString: teamIconUrl)) {
            self.profileImageView.image = UIImage(named: "user_male_circle")
            self.activityIndicator.stopAnimating()
            alert(title: "Error", msg:"Invalid Url")
            return
        }
        
        let imgURL = URL(string: teamIconUrl)
       
        URLSession.shared.dataTask(with: imgURL!, completionHandler: { (data, response, error) in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            DispatchQueue.main.async(execute: {
                if let downloadImage = UIImage(data: data!){
                    self.profileImageView.image = downloadImage
                    self.view.layoutIfNeeded()
                    self.activityIndicator.stopAnimating()
                }
            })
        }).resume()
    }
    
    override func viewDidLayoutSubviews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
    }
    
    @objc func handleSubmit() {
        self.view.endEditing(true)
        if teamNameTextField.text == "" || teamIconTextField.text == "" {
            alert(title: "Error", msg:"Form is not valid")
            return
        }
    
        activityIndicator.startAnimating()
        
        guard let teamName = teamNameTextField.text, let teamIcon = teamIconTextField.text else {
            return
        }
        
        let newTeam: [String: String] = [   "teamName": teamName,
                                            "teamIcon": teamIcon
                                        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: newTeam)

        let newTeamURL = URL(string: "\(TeamTracker.serverHostUrl)/register/team")
        var request = URLRequest(url: newTeamURL!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let err = error{
                print(err.localizedDescription)
                DispatchQueue.main.async(execute: {
                    self.alert(title: "Error", msg: "\(err.localizedDescription)")
                })
                return
            }
            DispatchQueue.main.async(execute: {
                self.newTeamDelegate.selectedImageUrl(imageName: teamName, imageUrl: teamIcon)
                self.activityIndicator.stopAnimating()
                self.alert(title: "", msg:"Successfully Registered")
            })
        }).resume()
    }
    
    @objc func handleCancel() {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func alert(title: String, msg: String){
        let alertVC = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        if title.isEmpty{
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
                self.dismiss(animated: true, completion: nil)
            }))
        }else{
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        }
        self.present(alertVC, animated: true, completion: nil)
    }
}


