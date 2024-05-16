//
//  Categories.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import Foundation

struct CategoryElement: Equatable {
    let categoryID: Int32
    let categoryName, iconName, color: String
}

typealias Category = [CategoryElement]
