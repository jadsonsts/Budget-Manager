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
    //var category: CategoryElement!

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
                dateLabel.text = formatDateString(dateString: transaction.date) 
                commentsLabel.text = transaction.comment
        
    }
    
    func formatDateString(dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "E, d MMM yyyy"
            let formattedDate = dateFormatter.string(from: date)
            return formattedDate
        }
        return nil
    }
    
}
