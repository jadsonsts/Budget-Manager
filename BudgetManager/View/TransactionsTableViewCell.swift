//
//  TransactionsTableViewCell.swift
//  BudgetManager
//
//  Created by Jadson on 20/02/23.
//

import UIKit

class TransactionsTableViewCell: UITableViewCell {
    
    let INCOME_FORMAT = "+$%.2f"
    let EXPENSE_FORMAT = "-$%.2f"

    @IBOutlet weak var referenceCell : UILabel!
    @IBOutlet weak var amountCell : UILabel!
    
    func updateViews(transaction: Transaction) {
        referenceCell.text = transaction.reference
        
        if transaction.transactionType == "income" { //change to enum if possible
            amountCell.text = String(format: INCOME_FORMAT, transaction.amount)
            amountCell.textColor = CustomColors.greenColor
            
        } else {
            amountCell.text = String(format: EXPENSE_FORMAT, transaction.amount)
            amountCell.textColor = CustomColors.expenseLabelColor
        }
        
    }

}
