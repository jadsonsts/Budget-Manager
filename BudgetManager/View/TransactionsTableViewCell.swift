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
    
    func updateViews(transaction: Transaction) {
        referenceCell.text = transaction.reference
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.positivePrefix = formatter.negativePrefix.replacingOccurrences(of: formatter.minusSign, with: formatter.plusSign)

        let positiveSign = formatter.string(for: transaction.amount)
        let negativeSign = formatter.string(for: -transaction.amount)
        
        amountCell.text = (transaction.transactionType == "income") ? positiveSign : negativeSign
        amountCell.textColor = (transaction.transactionType == "income") ? CustomColors.greenColor : CustomColors.expenseLabelColor
    }
}
