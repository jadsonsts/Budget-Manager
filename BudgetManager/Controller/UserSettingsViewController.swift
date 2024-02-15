//
//  UserSettingsViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.


import UIKit
import ProgressHUD
import FirebaseAuth

class UserSettingsViewController: UIViewController {
    
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var firstNameTextField: CustomTxtField!
    @IBOutlet weak var lastNameTextField: CustomTxtField!
    @IBOutlet weak var emailTextField: CustomTxtField!
    @IBOutlet weak var phoneNumberTextField: CustomTxtField!
    @IBOutlet weak var passwordTextField: CustomTxtField!
    @IBOutlet weak var confirmPasswordTextField: CustomTxtField!
    @IBOutlet weak var updateProfileButton: CustomButton!
    @IBOutlet weak var disclaimerLabel: UILabel!
    
    var userDetails: Customer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        loadProfilePicture()
        updateProfileButton.isHidden = true
        passwordTextField.isHidden = true
        confirmPasswordTextField.isHidden = true
        createKeyboardDoneButton()
        disclaimerLabel.text = "⚠️ User profile will be available for editing in the future updates ⚠️"
        userProfilePicture.layer.cornerRadius = 40
        userProfilePicture.clipsToBounds = true

    }
    
    func loadLabels() {
        firstNameTextField.text = userDetails?.name
        lastNameTextField.text = userDetails?.familyName
        emailTextField.text = userDetails?.email
        phoneNumberTextField.text = userDetails?.phone
        
    }
    
    func loadProfilePicture() {
        DataController.shared.loadPhoto { [weak self] customerImage in
            //safeImage is the check from userDefaults, if there's no image, the app will check on firebase
            if let safeImage = customerImage {
                self?.userProfilePicture.image = safeImage
            } else {
                DataController.shared.downloadPhotoFromFirebase { [weak self] userProfilePicture in
                    self?.userProfilePicture.image = userProfilePicture
                }
            }
        }
    }
    
    func loadUserData()  {
        ProgressHUD.show()
        guard let userID = Auth.auth().currentUser?.uid else { return }
        DataController.shared.fetchCustomer(userID) { [weak self] customer in
            self?.userDetails = customer
            self?.loadLabels()
            ProgressHUD.dismiss()
        } onError: { errorMessage in
            ProgressHUD.showFailed(errorMessage)
        }
        
    }

    @IBAction func updateProfileButtonPressed(_ sender: CustomButton) {
    }

}

//MARK: - Keyboard Settings
extension UserSettingsViewController {
    func createKeyboardDoneButton() {
        let textFields: [UITextField] = [lastNameTextField, firstNameTextField, emailTextField, phoneNumberTextField, passwordTextField, confirmPasswordTextField]
        
        UIViewController.addDoneButtonOnKeyboard(for: textFields, target: self, selector: #selector(doneButtonAction))
    }
    
    @objc func doneButtonAction(){
        view.endEditing(true)
    }
}
