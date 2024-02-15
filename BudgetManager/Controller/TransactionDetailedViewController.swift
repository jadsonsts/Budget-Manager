//
//  TransactionDetailedViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import ProgressHUD

class TransactionDetailedViewController: UIViewController {
    
    @IBOutlet weak var transactionTypeLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var detailAmountLabel: UILabel!
    @IBOutlet weak var referenceLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    var updateTransactionDelegate: InputTransactionDelegate?
    var transaction: Transaction!
    var categoryName: String?
    var category: CategoryElement?
    var wallet: Wallet?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCategory()
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if let transaction = transaction {
            performSegue(withIdentifier: K.editTransaction, sender: transaction)
        }
    }
    
    func fetchCategory() {
        ProgressHUD.show()
        let categoryID = transaction.categoryID
        DataController.shared.fetchCategory(categoryID: categoryID) { [weak self] category in
            self?.category = category
            self?.categoryName = category.categoryName
            self?.loadData()
            ProgressHUD.dismiss()
        } onError: { errorMessage in
            ProgressHUD.showError("Unable to fetch category Name")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? InputTransactionTableViewController {
            if let transaction = sender as? Transaction {
                destination.transactionToEdit = transaction
                destination.category = category
                destination.wallet = wallet
                destination.inputTransactionDelegate = self.updateTransactionDelegate
            }
        }
    }
    
    func loadData() {
        guard let safeCategoryName = categoryName else { return }
        
        transactionTypeLabel.text = transaction.transactionType
        amountLabel.text = String(format: " $%.2f", transaction.amount)
        detailAmountLabel.text = String(format: "$%.2f", transaction.amount)
        referenceLabel.text = transaction.reference
        categoryLabel.text = safeCategoryName
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

extension TransactionDetailedViewController: InputTransactionDelegate {
    func didUpdateHomeView() {
        
    }
}
