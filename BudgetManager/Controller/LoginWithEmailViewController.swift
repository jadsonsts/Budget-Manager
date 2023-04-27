//
//  LoginWithEmailViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import FirebaseAuth
import ProgressHUD

class LoginWithEmailViewController: UIViewController {

    @IBOutlet weak var emailTxtField: CustomTxtField!
    @IBOutlet weak var passwordTxtField: CustomTxtField!
    @IBOutlet weak var loginButton: CustomButton!
    
    @IBOutlet weak var emailMesageErrorLabel: UILabel!
    @IBOutlet weak var passwordMessageErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailMesageErrorLabel.isHidden = true
        passwordMessageErrorLabel.isHidden = true
    }
    
    func validateFields() -> (email: String, password: String)?{
        guard let email = emailTxtField.text else {
            emailMesageErrorLabel.isHidden = false
            emailMesageErrorLabel.text = ErrorMessageType.validEmail.message()
            return nil
        }
        emailMesageErrorLabel.isHidden = true
        
        guard let password = passwordTxtField.text else {
            passwordMessageErrorLabel.isHidden = false
            passwordMessageErrorLabel.text = ErrorMessageType.notEmpty.message()
            return nil
        }
        passwordMessageErrorLabel.isHidden = true 
        return (email, password)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        guard let fields = validateFields() else { return }
        ProgressHUD.show()
        DataController.shared.signIn(withEmail: fields.email, password: fields.password) {
            ProgressHUD.showSuccess()
            print("success")
            //send to mainVC
            //call the fetch user + wallet + transaction functions
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }

//        if let email = emailTxtField.text,
//           let password = passwordTxtField.text {
//            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//                if let e = error {
//                    print (e.localizedDescription) //put alert for user
//                } else {
//                    self.performSegue(withIdentifier: K.loginSegue, sender: self)
//                    //FUNC FOR RETRIEVE THE DATA FROM DB (USE ASYNC?)
//                }
//            }
//        }
    }
}
