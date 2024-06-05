//
//  Wallet.swift
//  Handy Budget - Expense Tracker
//
//  Created by Jadson on 7/02/23.
//

import Foundation
import CoreData

extension Wallet {
    func calculateAmount() -> Double {
        var amount: Double = 0.0
        let transactions = self.transaction?.allObjects as? [Transaction] ?? []
        for transaction in transactions {
            if transaction.transactionType == "income" {
                amount += transaction.amount
            } else if transaction.transactionType == "expense" {
                amount -= transaction.amount
            }
        }
        
        if let updatedTransaction = transactions.first(where: {$0.isModified }) {
            if updatedTransaction.transactionType == "income" {
                amount += updatedTransaction.amount - updatedTransaction.amount
            } else if updatedTransaction.transactionType == "expense" {
                amount -= updatedTransaction.amount - updatedTransaction.amount
            }
            updatedTransaction.isModified = false
        }
        return amount
    }
}
