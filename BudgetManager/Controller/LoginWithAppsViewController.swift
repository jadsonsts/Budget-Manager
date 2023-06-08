//
//  ViewController.swift
//  BudgetManager
//
//  Created by Jadson on 6/02/23.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseCore
import ProgressHUD

class LoginWithAppsViewController: UIViewController {

    @IBOutlet weak var signInGoogleButton: CustomButton!
    @IBOutlet weak var signInFacebookButton: CustomButton! //FBLoginButton! // FBSDKLoginButton
    @IBOutlet weak var signInAppleButton: CustomButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtonUI()
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: K.userLoggedInHome, sender: self)
        }
        
        /*       if let fbToken = AccessToken.current,
         !fbToken.isExpired {
         // User is logged in, do work such as go to next view controller.
         } else {
         //signInFacebookButton.permissions = ["public_profile", "email"]
         // signInFacebookButton.delegate = self
         }*/
    }

    // setting button title and image
    func setupButtonUI() {

        setupButton(signInGoogleButton, title: "Sign in with Google", imageName: "iconGoogle", background: .white)
        setupButton(signInFacebookButton, title: "Sign in with Facebook", imageName: "iconFacebook", background: CustomColors.fbColor)
        setupButton(signInAppleButton, title: "Sign in with Apple", imageName: "iconApple", background: .black)
        
    }
    
    func setupButton(_ button: UIButton, title: String, imageName: String,  background: UIColor) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = background
        if let image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal) {
            button.setImage(image, for: .normal)
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: -20, bottom: 12, right: 220)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -120, bottom: 0, right: 0)
    }
    
    @IBAction func signInWithGoogle(sender: CustomButton) {

//        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
//            guard error == nil else { return }
//
//            guard let signInResult = signInResult else { return }
//
//            let user = signInResult.user
//
//           if let emailAddress = user.profile?.email,
//              let givenName = user.profile?.givenName,
//              let familyName = user.profile?.familyName ,
//              let profilePicUrl = user.profile?.imageURL(withDimension: 320) {
//
//               print (emailAddress, givenName, familyName, profilePicUrl)
//
//           }
            
            // If sign in succeeded, display the app's main content View.
            //perfom request with token to retrieve user data (API)
            //send to home view controller
        //}
    }

    @IBAction func signInWithFacebook(_ sender: CustomButton) {
        ProgressHUD.show("Not yet available, please try another sign-in method", icon: .exclamation)
    }
    
    @IBAction func signInWithApple(_ sender: CustomButton) {
        ProgressHUD.show("Not yet available, please try another sign-in method", icon: .exclamation)
    }
}

extension LoginWithAppsViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        let token = result?.token?.tokenString
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                 parameters: ["fields": "email, name"], //these are the permission given when the button is pressed (see viewDidload)
                                                 tokenString: token,
                                                 version: nil,
                                                 httpMethod: .get)
        request.start(completion: { connection, result, error in
            print(":\(String(describing: result))")
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        print("logout")
    }
    
}
