//
//  Transactions.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation

struct Transactions: Identifiable {
    var id: Int
    var category: [Categories]
    var amount: Double
    var reference: String
    var date: Date
    var comments: String
    var transactionType: String
}
