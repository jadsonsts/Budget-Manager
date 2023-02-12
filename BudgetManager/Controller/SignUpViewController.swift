//
//  SignUpViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit

class SignUpViewController: UIViewController {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var firstNameTxtField: CustomTxtField!
    @IBOutlet weak var lastNameTxtField: CustomTxtField!
    @IBOutlet weak var emailTxtField: CustomTxtField!
    @IBOutlet weak var phoneTxtField: CustomTxtField!
    @IBOutlet weak var passwordTxtField: CustomTxtField!
    @IBOutlet weak var confirmPasswordTxtField: CustomTxtField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func signUpPressed(_ sender: CustomButton) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
