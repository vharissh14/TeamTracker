//
//  ViewController.swift
//  UserRegistration
//
//  Created by Shaik on 12/10/17.
//  Copyright © 2017 Astro1. All rights reserved.
//

import UIKit

class LoginController: UIViewController {
 
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor(r: 255, g: 255, b: 255), for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    let facebookButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Login With Facebook", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor(r: 255, g: 255, b: 255), for: UIControlState())
        button.setImage(#imageLiteral(resourceName: "icons8-facebook"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleCustomFBLogin), for: UIControlEvents.touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    let googleButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Login With Google", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(UIColor(r: 255, g: 255, b: 255), for: UIControlState())
        button.setImage(#imageLiteral(resourceName: "icons8-google"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(handleCustomGoogleLogin), for: UIControlEvents.touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    lazy var nameTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 100
        tf.delegate = self
        tf.placeholder = "Name"
        tf.keyboardType = UIKeyboardType.alphabet
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
       
        return view
    }()
    
    lazy var pSeudoNameTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 103
        tf.delegate = self
        tf.placeholder = "Pseudo Name"
        tf.keyboardType = UIKeyboardType.alphabet
        tf.translatesAutoresizingMaskIntoConstraints = false
       
        return tf
    }()
    
    let pSeudoNameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
       
        return view
    }()
    
    lazy var phoneNumberTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 102
        tf.delegate = self
        tf.placeholder = "Phone Number"
        tf.keyboardType = UIKeyboardType.phonePad
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let phoneNumberSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
       
        return view
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 101
        tf.delegate = self
        tf.placeholder = "Email"
        tf.keyboardType = UIKeyboardType.emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var teamNameTextField: DropDownTxtField = {
        let tf = DropDownTxtField()
        tf.tag = 104
        tf.delegate = self
        tf.teamDelegate = self
        tf.placeholder = "Team Name"
        tf.keyboardType = UIKeyboardType.alphabet
        tf.translatesAutoresizingMaskIntoConstraints = false

        return tf
    }()
    
    lazy var newTeamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "plus-icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleNewTeam)))
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let teamNameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var missionNameTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 106
        tf.delegate = self
        tf.placeholder = "Event Name"
        tf.keyboardType = UIKeyboardType.alphabet
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let missionNameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
       
        return view
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.tag = 105
        tf.delegate = self
        tf.placeholder = "Password"
        tf.keyboardType = UIKeyboardType.alphabet
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
      
        return tf
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
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
       
        return sc
    }()
    
    lazy var myActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        return activityIndicator
    }()
    
    var users = [[String: AnyObject]]()
    var currentUser = String()
    
    var teamlist = [[String: AnyObject]]()
    var selectedImageUrl = String()
   
    var inputsContainerViewCenterYAnchor: NSLayoutConstraint?
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var inputsContainerViewBottomAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var pSeudoNameTextFieldHeightAnchor: NSLayoutConstraint?
    var phoneNumberTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var teamNameTextFieldHeightAnchor: NSLayoutConstraint?
    var teamNameSeparatorHeightAnchor: NSLayoutConstraint?
    var missionNameTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    var activityIndicatorCenterXAnchor: NSLayoutConstraint?
    var activityIndicatorCenterYAnchor: NSLayoutConstraint?
    
    var appDelegate: AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        setupArchitectView()
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(myActivityIndicator)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        view.addSubview(facebookButton)
        view.addSubview(googleButton)
        view.bringSubview(toFront: myActivityIndicator)
        
        customizeNavBar()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupActivityIndicator()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
        setupFacebookButton()
        setupGoogleButton()
        
        GIDSignIn.sharedInstance().clientID = "672999483819-5beedqlvdhenrgkekit2te018ail10l3.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        getTeamNames()
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handleLoginRegisterChange()
        appDelegate?.statusBarBackgroundView?.isHidden = UIDevice.current.orientation.isLandscape
        observeKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        if UIDevice.current.orientation.isLandscape {
            print("landscape")
            appDelegate?.statusBarBackgroundView?.isHidden = true

        } else {
            print("portrait")
            appDelegate?.statusBarBackgroundView?.isHidden = false

        }
    }
    
    override func viewDidLayoutSubviews() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
    }

}







