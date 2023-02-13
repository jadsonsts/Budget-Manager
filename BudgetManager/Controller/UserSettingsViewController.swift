//
//  UserSettingsViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit

class UserSettingsViewController: UIViewController {
    
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var userName: CustomTxtField!
    @IBOutlet weak var lastName: CustomTxtField!
    @IBOutlet weak var email: CustomTxtField!
    @IBOutlet weak var phoneNumber: CustomTxtField!
    @IBOutlet weak var password: CustomTxtField!
    @IBOutlet weak var confirmPassword: CustomTxtField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateProfileButtonPressed(_ sender: CustomButton) {
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
