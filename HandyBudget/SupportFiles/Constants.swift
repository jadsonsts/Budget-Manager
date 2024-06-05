//
//  File.swift
//  BudgetManager
//
//  Created by Jadson on 8/02/23.
//

import Foundation

struct K {
    static let loginSegue = "LoginToHome"
    static let registerSegue = "RegisterToHome"
    static let detailSegue = "GoToTransactionDetail"
    static let transactionCell = "TransactionCell"
    static let categoryCell = "CategoryCell"
    static let categorySelection = "GoToSelectCategory"
    static let editTransaction = "editTransaction"
    static let unwindToHome = "unwindToHome"
    static let goToAbout = "AboutSegue"
    static let goToUserSettings = "UserSettings"
    //static let userLoggedInHome = "AlreadyLoggedIn"
    static let newTransaction = "SendToTransaction"
}

struct A {
    //HomeViewController
    static let searchPressed = "search_pressed"
    static let searchText = "search_text"
    
    //MenuViewController
    static let aboutPressed = "about_button_pressed"
    static let userSettingsPressed = "user_settings_button_pressed"
    
    //TransactionDetailedViewController
    static let editPressed = "edit_button_tapped"
    static let transactionType = "type_of_transaction"
    static let transactionAmount = "transaction_value"
    static let transactionCategory = "category_of_transaction"
    
    //InputTransactionViewController
    static let transactionAmountRange = "transaction_amount_range"
    static let transaction = "transaction"
    static let isTransactionModified = "edit"
    static let selectedCategory = transactionCategory
    
    static let signOutPressed = "user_sign_out"
    static let userDeleted = "user_delete_account"
    
    static let userName = "user_name"

}
