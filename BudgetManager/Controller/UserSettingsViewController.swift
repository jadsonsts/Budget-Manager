//
//  UserSettingsViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit

class UserSettingsViewController: UIViewController {
    
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var firstNameTextField: CustomTxtField!
    @IBOutlet weak var lastNameTextField: CustomTxtField!
    @IBOutlet weak var emailTextField: CustomTxtField!
    @IBOutlet weak var phoneNumberTextField: CustomTxtField!
    @IBOutlet weak var passwordTextField: CustomTxtField!
    @IBOutlet weak var confirmPasswordTextField: CustomTxtField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createKeyboardDoneButton()

        // Do any additional setup after loading the view.
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
