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
    
    //Validation Supporters
    @IBOutlet weak var emailValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    @IBOutlet weak var passwordImageViewValidation: UIImageView!
    @IBOutlet weak var firstNameValidationLabel: UILabel!
    @IBOutlet weak var familyNameValidationLabel: UILabel!
    @IBOutlet weak var phoneValidationLabel: UILabel!
    @IBOutlet weak var confPasswordValidationLabel: UILabel!
    @IBOutlet weak var passwordCheckStackView: UIStackView!
    
    
    let passwordValidation = PasswordValidationObj()
    
    var validationLabels: [UILabel] = []
    var validationImageViews: [UIImageView] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstNameValidationLabel.isHidden = true
        familyNameValidationLabel.isHidden = true
        emailValidationLabel.isHidden = true
        phoneValidationLabel.isHidden = true
        confPasswordValidationLabel.isHidden = true
        hidePasswordCheckStackView()
        
        
        passwordTxtField.delegate = self
        passwordValidation.onChange = { [weak self] _ in
            guard let self = self else { return }
            self.updatePasswordValidationLabel()
            self.updatePasswordValidationImage()
        }
    }
    // Updates the password validation label
    func updatePasswordValidationLabel() {
        let validations = passwordValidation.validations
        
        // Create the validation string
        var validationString = ""
        var isValid = true
        for validation in validations {
            if validation.state == .success {
                validationString += "✔︎ "
            } else {
                validationString += "✖︎ "
                isValid = false
            }
            validationString = validation.validationType.message(fieldName: validationString) + "\n"
        }
        
        // Update the label
        passwordValidationLabel.text = validationString
        
        if isValid {
            insertImageRightTextField(textField: passwordTxtField, error: false)
        } else {
            insertImageRightTextField(textField: passwordTxtField, error: true)
        }
        
    }
    
    // Updates the password validation image
    func updatePasswordValidationImage() {
        let validations = passwordValidation.validations
        let isValid = passwordValidation.isValid
        
        // Show the appropriate image
        if isValid {
            passwordImageViewValidation.image = UIImage(systemName: "checkmark.circle")
            hidePasswordCheckStackView()
        } else {
            passwordImageViewValidation.image = UIImage(systemName: "xmark.circle")
        }
        
        // Update the tintColor of the image based on the state of each validation
        for validation in validations {
            if validation.state == .success {
                passwordImageViewValidation.tintColor = UIColor.green
            } else {
                passwordImageViewValidation.tintColor = UIColor.red
                break
            }
        }
    }
    
    @IBAction func emailTxtFieldChanged(_ sender: CustomTxtField) {
        let email = sender.text ?? ""
        if !email.isValidEmail(email) {
            emailValidationLabel.isHidden = false
            emailValidationLabel.text = "Please insert a valid email."
            insertImageRightTextField(textField: emailTxtField, error: true)
        } else {
            emailValidationLabel.isHidden = true
            emailValidationLabel.text = ""
            insertImageRightTextField(textField: emailTxtField, error: false)
        }
    }
    
    @IBAction func firstNameTxtChanged(_ sender: CustomTxtField) {
        let name = sender.text ?? ""
        if name.count == 0 {
            firstNameValidationLabel.text = "Name cannot be empty"
            UIView.animate(withDuration: 0.3) {
                self.firstNameValidationLabel.isHidden = false
                self.insertImageRightTextField(textField: self.firstNameTxtField, error: true)
            }
        } else {
            firstNameValidationLabel.text = ""
            UIView.animate(withDuration: 0.3) {
                self.firstNameValidationLabel.isHidden = true
                self.insertImageRightTextField(textField: self.firstNameTxtField, error: false)
            }
        }
    }
    
    @IBAction func lastNameTxtChanged(_ sender: CustomTxtField) {
        
    }
    
    
    @IBAction func phoneTxtChanged(_ sender: CustomTxtField) {
    }
    
    @IBAction func confPasswordTxtChanged(_ sender: CustomTxtField) {
        if let password = passwordTxtField.text {
            let confPassword = sender.text ?? ""
            if confPassword != password {
                confPasswordValidationLabel.text = "Password and Confirm Password fields must be the same"
                self.insertImageRightTextField(textField: self.confirmPasswordTxtField, error: true)
                UIView.animate(withDuration: 0.3) {
                    self.confPasswordValidationLabel.isHidden = false
                }
            } else {
                self.insertImageRightTextField(textField: self.confirmPasswordTxtField, error: false)
                UIView.animate(withDuration: 0.3) {
                    self.confPasswordValidationLabel.isHidden = true
                }
            }
        } else {
            confirmPasswordTxtField.isEnabled = false
        }
    }
    
    func showPasswordCheckStackView() {
        UIView.animate(withDuration: 0.3) {
            self.passwordCheckStackView.isHidden = false
            self.passwordCheckStackView.alpha = 1.0
        }
    }
    
    func hidePasswordCheckStackView() {
        UIView.animate(withDuration: 0.3) {
            self.passwordCheckStackView.alpha = 0.0
        } completion: { _ in
            self.passwordCheckStackView.isHidden = true
        }
    }
    
    func insertImageRightTextField(textField: UITextField, error: Bool) {
        if error {
            textField.rightViewMode = .always
            textField.rightView = UIImageView(image: UIImage(systemName: "xmark.circle"))
            textField.rightView?.tintColor = CustomColors.expenseLabelColor
        } else {
            textField.rightViewMode = .always
            textField.rightView = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
            textField.rightView?.tintColor = CustomColors.greenColor
        }
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

extension SignUpViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        showPasswordCheckStackView()
        let currentText = textField.text ?? ""
        passwordCheckStackView.isHidden = false
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        passwordValidation.password = updatedText
        
        return true
    }
}
