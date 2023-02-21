//
//  Wallet.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation

struct Wallet: Codable {
    var name: String
    var amount: Double
    var transactions: [Transactions]
}
