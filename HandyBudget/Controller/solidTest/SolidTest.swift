//
//  SolidTest.swift
//  HandyBudget
//
//  Created by Jadson on 12/08/2024.
//


import UIKit
import ProgressHUD

struct ValidateFields {
    
    let name: UITextField
    let email: UITextField
    let password: UITextField
    let confPassword: UITextField
    
    func validateFields() -> (name: String, email: String, password: String, confPassword: String)? {
        guard let name = name.text, !name.isEmpty,
              let email = email.text, !email.isEmpty,
              let password = password.text, !password.isEmpty,
              let confPassword = confPassword.text, !confPassword.isEmpty else {
            ProgressHUD.failed(ErrorMessageType.emptyForm.message())
            return nil
        }
        return (name, email, password, confPassword)
    }
}
