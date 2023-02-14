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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let loginButton = FBLoginButton()
        loginButton.center = view.center
        view.addSubview(loginButton)
        loginButton.permissions = ["public_profile", "email"]
        
        if let fbToken = AccessToken.current,
           !fbToken.isExpired {
            // User is logged in, do work such as go to next view controller.
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

