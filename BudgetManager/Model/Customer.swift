//
//  Customer.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation


struct Customer: Codable {
    let id: Int
    let firebaseID, name, familyName, email: String
    let phone, profilePicture: String
    let isActive: Bool
}
