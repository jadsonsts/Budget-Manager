//
//  Transactions.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation

struct Transaction: Codable {
    let id: Int
    let reference: String
    let amount: Double
    let date, comment, transactionType: String
    let walletID, categoryID: Int
}

typealias Transactions = [Transaction]

