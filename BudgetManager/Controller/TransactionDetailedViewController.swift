//
//  TransactionDetailedViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import ProgressHUD
import FirebaseDatabase
import FirebaseAnalytics

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
    
    let databaseRef = Database.database().reference()
    
    lazy var amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }()
    
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
            Analytics.logEvent(A.editPressed, parameters: [
                A.transactionType : transaction.transactionType!,
                A.transactionAmount : transaction.amount,
                A.transactionCategory : transaction.categoryID,
            ])
            performSegue(withIdentifier: K.editTransaction, sender: transaction)
        }
    }
    
    func fetchCategory() {
        ProgressHUD.animate("Loading Transaction Details", .barSweepToggle)
        let categoryID = transaction.categoryID
        DataController.shared.fetchCategoryById(categoryID: categoryID) { [weak self] categoryValue in
            self?.category = categoryValue
            self?.loadData(for: categoryValue.categoryName)
            ProgressHUD.dismiss()
        } onError: { errorMessage in
            self.category = nil
            self.categoryName = "Not Set"
            self.loadData()
            ProgressHUD.failed("Unable to fetch category Name")
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
    
    func loadData(for categoryName: String? = "") {
        guard let safeCategoryName = categoryName else { return }
        
        transactionTypeLabel.text = transaction.transactionType
        amountLabel.text = formatNumber(number: transaction.amount)
        detailAmountLabel.text = formatNumber(number: transaction.amount)
        referenceLabel.text = transaction.reference
        categoryLabel.text = safeCategoryName
        dateLabel.text = formatDate(dateString: transaction.date ?? Date())
        commentsLabel.text = transaction.comments
    }
    
    func formatDate(dateString: Date) -> String {
        let date = dateString.formatted(Date.FormatStyle()
            .weekday(.wide)
            .day(.twoDigits)
            .month(.abbreviated)
            .year(.defaultDigits))
        return date
    }
    
    func formatNumber(number: Double) -> String {
        return amountFormatter.string(for: number) ?? "Failed fetching amount"
    }
}
