//
//  SignUpViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import FirebaseStorage
import ProgressHUD

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
    @IBOutlet weak var lastNameValidationLabel: UILabel!
    @IBOutlet weak var phoneValidationLabel: UILabel!
    @IBOutlet weak var confPasswordValidationLabel: UILabel!
    @IBOutlet weak var passwordCheckStackView: UIStackView!
    @IBOutlet weak var imageValidationLabel: UILabel!
    
    let passwordValidation = PasswordValidationObj()
    var image: UIImage? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageValidationLabel.isHidden = true
        firstNameValidationLabel.isHidden = true
        lastNameValidationLabel.isHidden = true
        emailValidationLabel.isHidden = true
        phoneValidationLabel.isHidden = true
        confPasswordValidationLabel.isHidden = true
        hidePasswordCheckStackView()
        setupProfilePicture()
        
        passwordTxtField.delegate = self
        passwordValidation.onChange = { [weak self] _ in
            guard let self = self else { return }
            self.updatePasswordValidationLabel()
            self.updatePasswordValidationImage()
        }
        
        createKeyboardDoneButton()
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
    
    func setupProfilePicture() {
        profilePictureImageView.layer.cornerRadius = 40
        profilePictureImageView.clipsToBounds = true
        profilePictureImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        profilePictureImageView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - TextField functions
    
    @IBAction func emailTxtFieldChanged(_ sender: CustomTxtField) {
        let email = sender.text ?? ""
        if !email.isValidEmail(email) {
            emailTxtField.showError()
            emailValidationLabel.isHidden = false
            emailValidationLabel.text = ErrorMessageType.validEmail.message()
            insertImageRightTextField(textField: emailTxtField, error: true)
        } else {
            emailTxtField.hideError()
            emailValidationLabel.isHidden = true
            emailValidationLabel.text = ""
            insertImageRightTextField(textField: emailTxtField, error: false)
        }
    }
    
    @IBAction func firstNameTxtChanged(_ sender: CustomTxtField) {
        let name = sender.text ?? ""
        if name.count == 0 {
            firstNameValidationLabel.text = ErrorMessageType.notEmpty.message()
            firstNameTxtField.showError()
            UIView.animate(withDuration: 0.3) {
                self.firstNameValidationLabel.isHidden = false
                self.insertImageRightTextField(textField: self.firstNameTxtField, error: true)
            }
        } else if !name.isValidName(name) {
            firstNameTxtField.showError()
            firstNameValidationLabel.text = ErrorMessageType.validName.message()
            UIView.animate(withDuration: 0.3) {
                self.firstNameValidationLabel.isHidden = false
                self.insertImageRightTextField(textField: self.firstNameTxtField, error: true)
            }
        } else {
            firstNameTxtField.hideError()
            firstNameValidationLabel.text = ""
            UIView.animate(withDuration: 0.3) {
                self.firstNameValidationLabel.isHidden = true
                self.insertImageRightTextField(textField: self.firstNameTxtField, error: false)
            }
        }
    }
    
    @IBAction func lastNameTxtChanged(_ sender: CustomTxtField) {
        let lastName = sender.text ?? ""
        if lastName.count == 0 {
            lastNameTxtField.showError()
            lastNameValidationLabel.text = ErrorMessageType.notEmpty.message()
            UIView.animate(withDuration: 0.3) {
                self.lastNameValidationLabel.isHidden = false
                self.insertImageRightTextField(textField: self.lastNameTxtField, error: true)
            }
        } else if !lastName.isValidName(lastName) {
            lastNameTxtField.showError()
            lastNameValidationLabel.text = ErrorMessageType.validName.message()
            UIView.animate(withDuration: 0.3) {
                self.lastNameValidationLabel.isHidden = false
                self.insertImageRightTextField(textField: self.lastNameTxtField, error: true)
            }
        } else {
            lastNameTxtField.hideError()
            lastNameValidationLabel.text = ""
            UIView.animate(withDuration: 0.3) {
                self.lastNameValidationLabel.isHidden = true
                self.insertImageRightTextField(textField: self.lastNameTxtField, error: false)
            }
        }
    }
    
    @IBAction func phoneTxtChanged(_ sender: CustomTxtField) {
        let phone = sender.text ?? ""
        if !phone.isValidPhoneNumber(phone) {
            phoneTxtField.showError()
            phoneValidationLabel.isHidden = false
            phoneValidationLabel.text = ErrorMessageType.validPhone.message()
            insertImageRightTextField(textField: phoneTxtField, error: true)
        } else {
            phoneTxtField.hideError()
            phoneValidationLabel.isHidden = true
            phoneValidationLabel.text = ""
            insertImageRightTextField(textField: phoneTxtField, error: false)
        }
    }
    
    @IBAction func confPasswordTxtChanged(_ sender: CustomTxtField) {
        if let password = passwordTxtField.text {
            let confPassword = sender.text ?? ""
            if confPassword != password {
                confirmPasswordTxtField.showError()
                confPasswordValidationLabel.text = ErrorMessageType.confirmationPassword.message()
                self.insertImageRightTextField(textField: self.confirmPasswordTxtField, error: true)
                UIView.animate(withDuration: 0.3) {
                    self.confPasswordValidationLabel.isHidden = false
                }
            } else {
                confirmPasswordTxtField.hideError()
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
    
//    func validateFields() -> Bool {
//        guard let name = firstNameTxtField.text, !name.isEmpty,
//              let lastName = lastNameTxtField.text, !lastName.isEmpty,
//              let phone = phoneTxtField.text, !phone.isEmpty,
//              let email = emailTxtField.text, !email.isEmpty,
//              let password = passwordTxtField.text, !password.isEmpty,
//              let confPassword = confirmPasswordTxtField.text, !confPassword.isEmpty else {
//                  ProgressHUD.showError(ErrorMessageType.emptyForm.message())
//            return false
//        }
//         return true
//    }
    
    func validateFields() -> (firstName: String, lastName: String, phone: String, email: String, password: String, confPassword: String)? {
        guard let firstName = firstNameTxtField.text, !firstName.isEmpty,
              let lastName = lastNameTxtField.text, !lastName.isEmpty,
              let phone = phoneTxtField.text, !phone.isEmpty,
              let email = emailTxtField.text, !email.isEmpty,
              let password = passwordTxtField.text, !password.isEmpty,
              let confPassword = confirmPasswordTxtField.text, !confPassword.isEmpty else {
            ProgressHUD.showError(ErrorMessageType.emptyForm.message())
            return nil
        }
        return (firstName, lastName, phone, email, password, confPassword)
    }

    @IBAction func signUpPressed(_ sender: CustomButton) {
        
        //checking if the image is available, if so, convert it to data to storage on firebase
        guard let imageSelected = self.image else {
            imageValidationLabel.isHidden = false
            imageValidationLabel.text = ErrorMessageType.noImage.message()
            return
        }
        imageValidationLabel.isHidden = true
        
        //unwrapping the function and if the fields are valid, pass them in the function to sign up on firebase and the server
        guard let fields = validateFields() else { return }
        ProgressHUD.show()
        DataController.shared.signUp(withEmail: fields.email , password: fields.password, image: imageSelected) {
            ProgressHUD.showSuccess()
            } onError: { errorMessage in
                ProgressHUD.showError(errorMessage)
            }
        

        //                else {
        //                    self.performSegue(withIdentifier: K.registerSegue, sender: self)
        //                    //func to send the rest of the data through API
        //                    if let userID = Auth.auth().currentUser?.uid {
        //                        print (userID)
        //                    }
        //                }
    }
    
    //MARK: - DONE BUTTON CREATION
    func createKeyboardDoneButton() {
        let textFields: [UITextField] = [lastNameTxtField, firstNameTxtField, emailTxtField, phoneTxtField, passwordTxtField, confirmPasswordTxtField]
        
        UIViewController.addDoneButtonOnKeyboard(for: textFields, target: self, selector: #selector(doneButtonAction))
    }
    
    @objc func doneButtonAction(){
        view.endEditing(true)
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

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func presentPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        let alertController = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
                picker.sourceType = .camera
                self.present(picker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }
            alertController.addAction(photoLibraryAction)
        }
        
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let originalImage = info[.originalImage] as? UIImage {
            profilePictureImageView.image = originalImage
            image = originalImage
        }
        picker.dismiss(animated: true)
    }
    
}
