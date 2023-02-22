//
//  Wallet.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation

struct Wallet: Codable {
    let walletName: String
    let amount: Int
    let transactions: [Transactions]
}
