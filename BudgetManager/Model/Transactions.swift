//
//  Transactions.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation

struct Transactions: Codable {
    let reference: String
    let amount: Int
    let date: String
    let category: CategoryElement
    let comments: String?
    let transactionType: String
    
    enum CodingKeys: String, CodingKey {
        case reference, amount, date, category, comments, transactionType
    }
}
