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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateProfileButton.isHidden = true
        createKeyboardDoneButton()
        disclaimerLabel.text = "⚠️ User profile will be available for editing in the next update ⚠️"

    }
    
    
    func createKeyboardDoneButton() {
        let textFields: [UITextField] = [lastNameTextField, firstNameTextField, emailTextField, phoneNumberTextField, passwordTextField, confirmPasswordTextField]
        
        UIViewController.addDoneButtonOnKeyboard(for: textFields, target: self, selector: #selector(doneButtonAction))
    }
    
    @objc func doneButtonAction(){
        view.endEditing(true)
    }
    
    @IBAction func updateProfileButtonPressed(_ sender: CustomButton) {
    }


}
