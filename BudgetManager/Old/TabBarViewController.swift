//
//  TabBarViewController.swift
//  BudgetManager
//
//  Created by Jadson on 1/06/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import ProgressHUD

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
   /*
    func fetchCustomer() {
    guard let userID = Auth.auth().currentUser?.uid else {
    ProgressHUD.showError("Error fetching user ID")
    return
    }
    DataController.shared.fetchCustomer(userID) { [weak self] customerResponse in
    UserVariables.customer = customerResponse
    if let customerID = customerResponse.id {
    self?.fetchWallet(customerID)
    } else {
    ProgressHUD.showError("An error ocurred")
    }
    } onError: { errorMessage in
    ProgressHUD.showError(errorMessage)
    }
    }
    
    func fetchWallet(_ customerID: Int) {
    
    DataController.shared.fetchUserWallet(for: customerID) { [weak self] walletResponse in
    UserVariables.wallet = walletResponse
    
    } onError: { errorMessage in
    ProgressHUD.showError(errorMessage)
    }
    }

    */
    

}



