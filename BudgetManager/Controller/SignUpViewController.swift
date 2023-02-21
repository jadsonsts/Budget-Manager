//
//  SignUpViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var firstNameTxtField: CustomTxtField!
    @IBOutlet weak var lastNameTxtField: CustomTxtField!
    @IBOutlet weak var emailTxtField: CustomTxtField!
    @IBOutlet weak var phoneTxtField: CustomTxtField!
    @IBOutlet weak var passwordTxtField: CustomTxtField!
    @IBOutlet weak var confirmPasswordTxtField: CustomTxtField!
    @IBOutlet weak var signUpButton: CustomButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signUpPressed(_ sender: CustomButton) {
//        while passwordTxtField.text == nil && confirmPasswordTxtField.text == passwordTxtField.text {
//            signUpButton.isEnabled = false
//        }
        if
           let email = emailTxtField.text,
           let password = passwordTxtField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription) //CREATE POPUP WITH THE ERROR
                } else {
                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
                    //func to send the rest of the data through API
                    if let userID = Auth.auth().currentUser?.uid {
                        print (userID)
                    }
                    
                }
                
            }
            
        }
    }
}
