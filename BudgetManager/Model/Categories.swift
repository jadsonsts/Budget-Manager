//
//  Categories.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation

struct CategoryElement: Codable, Equatable {
    let id: Int
    let name, iconName, color: String
}

typealias Category = [CategoryElement]
