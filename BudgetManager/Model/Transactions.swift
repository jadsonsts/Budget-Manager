//
//  Transactions.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation

struct Transaction: Codable {
    let reference: String
    let amount: Int
    let date, category: String
    let comments: String?
    let transactionType: String
}
