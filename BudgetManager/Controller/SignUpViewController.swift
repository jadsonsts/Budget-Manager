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
    
    //Validation Supporter
    @IBOutlet weak var emailValidationLabel: UILabel!
    @IBOutlet weak var passwordValidationLabel: UILabel!
    @IBOutlet weak var passwordImageViewValidation: UIImageView!
    
    let passwordValidation = PasswordValidationObj()
    var validationLabels: [UILabel] = []
    var validationImageViews: [UIImageView] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailValidationLabel.isHidden = true
        
        // Set up your password text field
        passwordValidation.password = ""
        passwordValidation.onChange = { [weak self] validation in
            // Update the UI to reflect the result of the validation
            for (index, validation) in validation.validations.enumerated() {
                let label = self?.validationLabels[index]
                let imageView = self?.validationImageViews[index]
                if validation.state == .success {
                    label?.textColor = .green
                    imageView?.image = UIImage(systemName: "checkmark.circle")
                    imageView?.tintColor = .green
                } else {
                    label?.textColor = .red
                    imageView?.image = UIImage(systemName: "xmark.circle")
                    imageView?.tintColor = .red
                }
            }
        }
        passwordTxtField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        errorMessageSetup()
        
    }
    
    func errorMessageSetup(){

        for validation in passwordValidation.validations {
            let label = UILabel()
            label.text = validation.validationType.message(fieldName: "Password")
            label.textColor = .red
            // Add the label to your view hierarchy below the password text field
            view.addSubview(label)
            validationLabels.append(label)
            
            let imageView = UIImageView()
            imageView.image = UIImage(systemName: "xmark.circle")
            imageView.tintColor = .red
            // Add the image view to your view hierarchy next to the corresponding label
            view.addSubview(imageView)
            validationImageViews.append(imageView)
            
            // Set up constraints to position the labels and image views
//            var previousLabel: UILabel?
//            for (index, label) in validationLabels.enumerated() {
//                let imageView = validationImageViews[index]
//
//                // Position the image view to the left of the label
//                NSLayoutConstraint.activate([
//                    imageView.centerYAnchor.constraint(equalTo: label.centerYAnchor),
//                    imageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -8),
//                    imageView.widthAnchor.constraint(equalToConstant: 24),
//                    imageView.heightAnchor.constraint(equalToConstant: 24)
//                ])
//
//                // Position the label below the previous label or below the password text field
//                if let previousLabel = previousLabel {
//                    NSLayoutConstraint.activate([
//                        label.topAnchor.constraint(equalTo: previousLabel.bottomAnchor, constant: 8),
//                        label.leadingAnchor.constraint(equalTo: previousLabel.leadingAnchor)
//                    ])
//                } else {
//                    NSLayoutConstraint.activate([
//                        label.topAnchor.constraint(equalTo: passwordTxtField.bottomAnchor, constant: 38),
//                        label.leadingAnchor.constraint(equalTo: passwordTxtField.leadingAnchor)
//                    ])
//                }
//
//                previousLabel = label
//            }
        }
        
    }
    
    
    @IBAction func emailTxtFieldChanged(_ sender: CustomTxtField) {
        let email = sender.text ?? ""
        if !email.isValidEmail(email) {
            emailValidationLabel.text = "Please insert a valid email"
            emailValidationLabel.isHidden = true
        }
        emailValidationLabel.isHidden = false
        emailValidationLabel.text = ""
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Update the password property of the passwordValidation object
        // whenever the text of the password text field changes
        passwordValidation.password = textField.text ?? ""
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
