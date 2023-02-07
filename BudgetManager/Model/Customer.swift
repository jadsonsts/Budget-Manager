//
//  Customer.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation
import UIKit

struct Customer: Identifiable {
    var id: Int
    var name: String
    var familyName: String
    var phone: Int
    var password: String
    var profilePicture: UIImage
    var wallet: Wallet
}
