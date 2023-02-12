//
//  LoginWithEmailViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit

class LoginWithEmailViewController: UIViewController {

    @IBOutlet weak var emailTxtField: CustomTxtField!
    @IBOutlet weak var passwordTxtField: CustomTxtField!
    @IBOutlet weak var logInButton: CustomButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func logInPressed(_ sender: Any) {
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
