//
//  LoginWithEmailViewController.swift
//  Handy Budget - Expense Tracker
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import FirebaseAuth
import FirebaseAnalytics
import ProgressHUD

class LoginWithEmailViewController: UIViewController {

    @IBOutlet weak var emailTxtField: CustomTxtField!
    @IBOutlet weak var passwordTxtField: CustomTxtField!
    @IBOutlet weak var loginButton: CustomButton!
    @IBOutlet weak var emailMesageErrorLabel: UILabel!
    @IBOutlet weak var passwordMessageErrorLabel: UILabel!
    
    var userID: String?
    
    lazy var passwordVisibilityButton: UIButton = {
        let button = UIButton(type: .custom)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -24, bottom: 0, right: 15)
        button.tintColor = CustomColors.greenColor
        return button
    }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordPrivacyToggle()
        UserDefaults.standard.removeObject(forKey: "imageURL")
        ProgressHUD.colorAnimation = CustomColors.greenColor
        if Auth.auth().currentUser != nil {
            performSegue(withIdentifier: K.loginSegue, sender: self)
        }
        createKeyboardDoneButton()

        emailMesageErrorLabel.isHidden = true
        passwordMessageErrorLabel.isHidden = true
    }
    
    func passwordPrivacyToggle() {
        passwordTxtField.rightViewMode = .whileEditing
        passwordVisibilityButton.setImage(UIImage(systemName: "eye"), for: .normal)
        passwordVisibilityButton.frame = CGRect(x: Int(passwordTxtField.frame.size.width) - 25, y: 5, width: 15, height: 25)
        passwordVisibilityButton.addTarget(self, action: #selector(self.passwordVisibilityButtonClicked), for: .touchUpInside)
        passwordTxtField.rightView = passwordVisibilityButton
    }
    
    @IBAction func passwordVisibilityButtonClicked(_ sender: UIButton) {
        passwordTxtField.isSecureTextEntry.toggle()
        let imageName = passwordTxtField.isSecureTextEntry ? "eye" : "eye.slash"
        passwordVisibilityButton.setImage(UIImage(systemName: imageName), for:.normal)
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
        ProgressHUD.animate("Loggin in...", .barSweepToggle)
        DataController.shared.signIn(withEmail: fields.email, password: fields.password) { [weak self] result in
            ProgressHUD.succeed()
            if let result = result {
                self?.userID = result.user.uid
                Analytics.logEvent(AnalyticsEventLogin, parameters: nil)
                self?.performSegue(withIdentifier: K.loginSegue, sender: self)
            }
        } onError: { errorMessage in
            ProgressHUD.failed(errorMessage)
        }
    }
//MARK: - Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.loginSegue {
            segue.destination.modalPresentationStyle = .currentContext
        } else {
            segue.destination.modalPresentationStyle = .currentContext
        }
    }
    
    //MARK: - DONE BUTTON CREATION
    func createKeyboardDoneButton() {
        let textFields: [UITextField] = [emailTxtField, passwordTxtField]
        UIViewController.addDoneButtonOnKeyboard(for: textFields, target: self, selector: #selector(doneButtonAction))
    }
    
    @objc func doneButtonAction(){
        view.endEditing(true)
    }
}
