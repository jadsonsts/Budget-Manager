//
//  ViewController.swift
//  BudgetManager
//
//  Created by Jadson on 6/02/23.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit



class LoginWithAppsViewController: UIViewController {

    @IBOutlet weak var signInGoogleButton: GIDSignInButton!
    @IBOutlet weak var signInFacebookButton: FBLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if let fbToken = AccessToken.current,
           !fbToken.isExpired {
            // User is logged in, do work such as go to next view controller.
        } else {
            signInFacebookButton.permissions = ["public_profile", "email"]
            signInFacebookButton.delegate = self
            signInFacebookButton.frame.size.height = 60
        }
        
    }
    
    @IBAction func signInWithGoogle(sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            
            // If sign in succeeded, display the app's main content View.
            //perfom request with token to retrieve user data (API)
            //send to home view controller
        }
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
            print("\(result)")
        })
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        print("logout")
    }
    
    
}

