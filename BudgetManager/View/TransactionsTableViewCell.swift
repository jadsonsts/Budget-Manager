//
//  TransactionsTableViewCell.swift
//  BudgetManager
//
//  Created by Jadson on 20/02/23.
//

import UIKit

class TransactionsTableViewCell: UITableViewCell {


    @IBOutlet weak var referenceCell : UILabel!
    @IBOutlet weak var amountCell : UILabel!
    
    func updateViews(transaction: Transactions) {
        referenceCell.text = transaction.reference
        
        if transaction.transactionType == "income" { //change to enum if possible
            amountCell.textColor = CustomColors.greenColor
            amountCell.text = String(format: "+$%.2f", transaction.amount)
        } else {
            amountCell.textColor = CustomColors.expenseLabelColor
            amountCell.text = String(format: "-$%.2f", transaction.amount)
        }
        
    }

}
