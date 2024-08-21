//
//  AuthService.swift
//  HandyBudget
//
//  Created by Jadson on 21/08/2024.
//

import Foundation
import FirebaseAuth
import ProgressHUD

struct AuthService {
    //create the user and save the profilePicute on firebase
    func signUp(userName: String, email: String, password: String, onSucess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { _ , error in
            if let error {
                ProgressHUD.failed(error.localizedDescription) //CHANGE THIS - REMOVE LOCALIZED DESCRIPTION
                return
            }
        }
    }
}
