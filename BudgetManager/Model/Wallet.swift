//
//  Wallet.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation

struct Wallet: Codable {
    let walletID: Int?
    let walletName: String
    let amount: Double
    let customerID: Int
    
    enum CodingKeys: String, CodingKey {
        case walletID, walletName, amount
        case customerID = "customer_ID"
    }
}
