//
//  LoginWithEmailViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import FirebaseAuth

class LoginWithEmailViewController: UIViewController {

    @IBOutlet weak var emailTxtField: CustomTxtField!
    @IBOutlet weak var passwordTxtField: CustomTxtField!
    @IBOutlet weak var logInButton: CustomButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logInPressed(_ sender: Any) {
        if let email = emailTxtField.text,
           let password = passwordTxtField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print (e.localizedDescription) //put alert for user
                } else {
                    self.performSegue(withIdentifier: K.loginSegue, sender: self)
                    //FUNC FOR RETRIEVE THE DATA FROM DB (USE ASYNC?)
                }
            }
        }
    }
}
