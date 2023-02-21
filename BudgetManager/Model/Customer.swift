//
//  Customer.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation


struct Customer: Codable {
    let id, name, familyName, email: String
    let phone: Int
    let profilePicture: String
    let wallet: Wallet
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name, familyName, email, phone, profilePicture, wallet
    }
}
