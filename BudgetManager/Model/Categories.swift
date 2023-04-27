//
//  Categories.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation

struct CategoryElement: Codable, Equatable {
    let categoryID: Int
    let categoryName, iconName, color: String
}

typealias Category = [CategoryElement]
