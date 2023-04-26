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

class LoginWithAppsViewController: UIViewController {

    @IBOutlet weak var signInGoogleButton: CustomButton!
    @IBOutlet weak var signInFacebookButton: CustomButton! //FBLoginButton! // FBSDKLoginButton
    @IBOutlet weak var signInAppleButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let fbToken = AccessToken.current,
           !fbToken.isExpired {
            // User is logged in, do work such as go to next view controller.
        } else {
            //signInFacebookButton.permissions = ["public_profile", "email"]
           // signInFacebookButton.delegate = self
        }
        
        setupButtonUI()
    }

    // setting button title and image
    func setupButtonUI() {
        
        let fbColor = UIColor(red: 0.26, green: 0.40, blue: 0.70, alpha: 1.00)
        
        setupButton(signInGoogleButton, title: "Login with Google", imageName: "iconGoogle", background: .white)
        setupButton(signInFacebookButton, title: "Login with Facebook", imageName: "iconFacebook", background: fbColor)
        setupButton(signInAppleButton, title: "Login with Apple", imageName: "iconApple", background: .black)
        
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
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            
            // If sign in succeeded, display the app's main content View.
            //perfom request with token to retrieve user data (API)
            //send to home view controller
        }
    }
    
    @IBAction func signInWithFacebook(_ sender: CustomButton) {
        
    }
    
    @IBAction func signInWithApple(_ sender: CustomButton) {
        
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

