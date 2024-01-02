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
    
    var userID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: K.loginSegue, sender: self)
        }

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
        ProgressHUD.colorAnimation = CustomColors.greenColor
        ProgressHUD.show()
        DataController.shared.signIn(withEmail: fields.email, password: fields.password) { result in
            ProgressHUD.showSuccess()
            if let result = result {
                self.userID = result.user.uid
                self.performSegue(withIdentifier: K.loginSegue, sender: self)
            }
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }
    }
//MARK: - Prepare for segue if necessary - send the user firebase ID
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.loginSegue {
            segue.destination.modalPresentationStyle = .currentContext
        }
    }
}
