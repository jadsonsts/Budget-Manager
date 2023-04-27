//
//  TransactionDetailedViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit

class TransactionDetailedViewController: UIViewController {
    
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var detailAmountLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    
    var transaction: Transaction!

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        
        
    }
    
    
    func loadData() {
                transactionTypeLabel.text = transaction.transactionType
                amountLabel.text = String(format: " $%.2f", transaction.amount)
                detailAmountLabel.text = String(format: "$%.2f", transaction.amount)
                referenceLabel.text = transaction.reference
                categoryLabel.text = String(transaction.categoryID) //change for name
                dateLabel.text = transaction.date
                commentsLabel.text = transaction.comment
        
    }
}
