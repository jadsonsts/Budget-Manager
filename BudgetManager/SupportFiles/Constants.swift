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
    static let userLoggedInHome = "LoginWithAppsToHome"
    static let editTransaction = "editTransaction"
}

struct UserVariables {
    static var customer: Customer?
    static var wallet: Wallet?
}
