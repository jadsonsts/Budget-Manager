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
import FirebaseAnalytics
import ProgressHUD
import Photos
import CoreData

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var firstNameTxtField: CustomTxtField!
    @IBOutlet weak var lastNameTxtField: CustomTxtField!
    @IBOutlet weak var emailTxtField: CustomTxtField!
    @IBOutlet weak var phoneTxtField: CustomTxtField!
    @IBOutlet weak var passwordTxtField: CustomTxtField!
    @IBOutlet weak var confirmPasswordTxtField: CustomTxtField!
    @IBOutlet weak var signUpButton: CustomButton!
    
    //MARK: - Validation Supporters
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
    var image: UIImage?
    lazy var passwordVisibilityButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -24, bottom: 0, right: 15)
        button.tintColor = CustomColors.greenColor
        return button
    }()
    
    lazy var confirmPasswordVisibilityButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -24, bottom: 0, right: 15)
        button.tintColor = CustomColors.greenColor
        return button
    }()
    
    let manager = CoreDataStack.shared
    
    override func viewWillAppear(_ animated: Bool) {
        hidePasswordCheckStackView()
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        passwordPrivacyToggle()
        confirmPasswordPrivacyToggle()
        hidePasswordCheckStackView()
        setupProfilePicture()
        hidesValidationLabels()
        passwordTxtField.delegate = self
        passwordValidation.onChange = { [weak self] _ in
            guard let self = self else { return }
            self.updatePasswordValidationLabel()
            self.updatePasswordValidationImage()
        }
        
        createKeyboardDoneButton()
    }
    
    func hidesValidationLabels() {
        imageValidationLabel.isHidden = true
        firstNameValidationLabel.isHidden = true
        lastNameValidationLabel.isHidden = true
        emailValidationLabel.isHidden = true
        phoneValidationLabel.isHidden = true
        confPasswordValidationLabel.isHidden = true
    }
    
    func passwordPrivacyToggle() {
        passwordTxtField.rightViewMode = .whileEditing
        passwordVisibilityButton.setImage(UIImage(systemName: "eye"), for: .normal)
        passwordVisibilityButton.frame = CGRect(x: Int(passwordTxtField.frame.size.width) - 25, y: 5, width: 15, height: 25)
        passwordVisibilityButton.addTarget(self, action: #selector(self.passwordVisibilityButtonClicked), for: .touchUpInside)
        passwordTxtField.rightView = passwordVisibilityButton
    }
    
    func confirmPasswordPrivacyToggle() {
        confirmPasswordTxtField.rightViewMode = .whileEditing
        confirmPasswordVisibilityButton.setImage(UIImage(systemName: "eye"), for: .normal)
        confirmPasswordVisibilityButton.frame = CGRect(x: Int(confirmPasswordTxtField.frame.size.width) - 25, y: 5, width: 15, height: 25)
        confirmPasswordVisibilityButton.addTarget(self, action: #selector(self.confirmPasswordVisibilityButtonClicked), for: .touchUpInside)
        confirmPasswordTxtField.rightView = confirmPasswordVisibilityButton
    }
    
    @IBAction func passwordVisibilityButtonClicked(_ sender: UIButton) {
        passwordTxtField.isSecureTextEntry.toggle()
        let imageName = passwordTxtField.isSecureTextEntry ? "eye" : "eye.slash"
        passwordVisibilityButton.setImage(UIImage(systemName: imageName), for:.normal)
    }
    
    @IBAction func confirmPasswordVisibilityButtonClicked(_ sender: UIButton) {
        confirmPasswordTxtField.isSecureTextEntry.toggle()
        let imageName = confirmPasswordTxtField.isSecureTextEntry ? "eye" : "eye.slash"
        confirmPasswordVisibilityButton.setImage(UIImage(systemName: imageName), for:.normal)
    }
    
    // Updates the password validation label
    func updatePasswordValidationLabel() {
        let validations = passwordValidation.validations
        
        // Create the validation string
        var validationString = ""
        for validation in validations {
            if validation.state == .success {
                validationString += "✔︎ "
            } else {
                validationString += "✖︎ "
            }
            validationString = validation.validationType.message(fieldName: validationString) + "\n"
        }
        // Update the label
        passwordValidationLabel.text = validationString
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
                passwordImageViewValidation.tintColor = CustomColors.greenColor
            } else {
                passwordImageViewValidation.tintColor = CustomColors.expenseLabelColor
                break
            }
        }
    }
    
    func setupProfilePicture() {
        profilePictureImageView.layer.cornerRadius = 40
        profilePictureImageView.clipsToBounds = true
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.image = UIImage(systemName: "photo.circle")
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
        if name.count == 0 || name.isEmpty || name == ""{
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
        if lastName.count == 0 || lastName.isEmpty || lastName == "" {
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
                UIView.animate(withDuration: 0.3) {
                    self.confPasswordValidationLabel.isHidden = false
                }
            } else {
                confirmPasswordTxtField.hideError()
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
    
    func validateFields() -> (firstName: String, lastName: String, phone: String, email: String, password: String, confPassword: String)? {
        guard let firstName = firstNameTxtField.text, !firstName.isEmpty,
              let lastName = lastNameTxtField.text, !lastName.isEmpty,
              let phone = phoneTxtField.text, !phone.isEmpty,
              let email = emailTxtField.text, !email.isEmpty,
              let password = passwordTxtField.text, !password.isEmpty,
              let confPassword = confirmPasswordTxtField.text, !confPassword.isEmpty else {
            ProgressHUD.failed(ErrorMessageType.emptyForm.message())
            return nil
        }
        return (firstName, lastName, phone, email, password, confPassword)
    }
    
    @IBAction func signUpPressed(_ sender: CustomButton) {
        //checking if the image is available
        guard let imageSelected = self.image else {
            imageValidationLabel.isHidden = false
            imageValidationLabel.text = ErrorMessageType.noImage.message()
            return
        }
        imageValidationLabel.isHidden = true
        
        //unwrapping the function and if the fields are valid, pass them in the function to sign up on firebase and the server
        guard let fields = validateFields() else { return }
        ProgressHUD.animate("Signin Up...", .barSweepToggle)
        let user = User(context: manager.context)
        let wallet = Wallet(context: manager.context)
        
        DataController.shared.signUp(withEmail: fields.email , password: fields.password, image: imageSelected) { [weak self] in
            guard let userID = Auth.auth().currentUser?.uid else { return }
            
            //create the user object to pass in to the core data context
            user.name = fields.firstName
            user.surname = fields.lastName
            user.email = fields.email
            user.phone = fields.phone
            user.firebase_ID = userID
            
            //create wallet object
            wallet.name = "Main"
            wallet.amount = 0.0
            wallet.user = user
            
            self?.manager.saveContext()
            self?.performSegue(withIdentifier: K.registerSegue, sender: self)
            ProgressHUD.dismiss()
            
        } onError: { errorMessage in
            ProgressHUD.failed(errorMessage)
        }
        Analytics.logEvent(AnalyticsEventSignUp, parameters: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.registerSegue {
            segue.destination.modalPresentationStyle = .currentContext
        }
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

//MARK: - Textfield Delegate
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

//MARK: - Image Picker Controller and Delegate
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func checkPhotoLibraryAuthorization() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
            case .authorized:
                openGaleryPicker()
            case .denied, .restricted :
                requestManualSettingForPhotoGaleryCamera()
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { [weak self] status in
                    DispatchQueue.main.async {
                        self?.checkPhotoLibraryAuthorization()
                    }
                }
            case .limited:
                openGaleryPicker()
        }
    }
    
    func openGaleryPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func checkCameraAuthorization() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
                    DispatchQueue.main.async {
                        self?.checkCameraAuthorization()
                    }
                }
            case .restricted, .denied:
                requestManualSettingForPhotoGaleryCamera()
            case .authorized:
                openCameraPicker()
        }
    }
    
    func openCameraPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    func requestManualSettingForPhotoGaleryCamera() {
        let alert = UIAlertController(title: "Manual settings required", message: "Please go to the app's settings and enable access to the photo library/camera", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alert.addAction(settingsAction)
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func presentPicker() {
        
        let alertController = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (action) in
                self?.checkCameraAuthorization()
            }
            alertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] (action) in
                self?.checkPhotoLibraryAuthorization()
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
        
        if let editedImage = info[.editedImage] as? UIImage {
            profilePictureImageView.image = editedImage
            image = editedImage
        }
        picker.dismiss(animated: true)
        imageValidationLabel.isHidden = true
    }
}
