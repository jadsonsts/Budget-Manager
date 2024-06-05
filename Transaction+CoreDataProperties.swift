//
//  Transaction+CoreDataProperties.swift
//  BudgetManager
//
//  Created by Jadson on 02/05/2024.
//  Handy Budget - Expense Tracker
//

import Foundation
import CoreData


extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "Transaction")
    }

    @NSManaged public var amount: Double
    @NSManaged public var categoryID: Int32
    @NSManaged public var comments: String?
    @NSManaged public var date: Date?
    @NSManaged public var reference: String?
    @NSManaged public var transactionType: String?
    @NSManaged public var isModified: Bool
    @NSManaged public var wallet: Wallet?

}

extension Transaction : Identifiable {

}
