//
//  InputTransactionTableViewController.swift
//  Handy Budget - Expense Tracker
//
//  Created by Jadson on 12/02/23.
//

import UIKit
import ProgressHUD
import CoreData
import FirebaseAnalytics

//typeAlias
let income = "income"
let expense = "expense"

protocol InputTransactionDelegate {
    func didUpdateHomeView()
}

class InputTransactionTableViewController: UITableViewController {
    
    @IBOutlet weak var transactionTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var transactionReferenceTxtField: UITextField!
    @IBOutlet weak var transactionAmountTxtField: UITextField!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var transactionDatePicker: UIDatePicker!
    @IBOutlet weak var transactionComments: UITextView!
    @IBOutlet weak var transactionDateLabel: UILabel!
    
    let manager = CoreDataStack.shared
    var inputTransactionDelegate: InputTransactionDelegate?
    var category: CategoryElement?
    var wallet: Wallet?
    var transactionToEdit: Transaction?
    var transactionType = income //set as default (income)
    var amount = 0
    let buttonSection = IndexPath(row: 0, section: 7)
    let transactionDateIndexPath = IndexPath(row: 1, section: 5)
    
    var isTransactionDatePickerShown: Bool = false {
        didSet {
            transactionDatePicker.isHidden = !isTransactionDatePickerShown
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if transactionToEdit != nil {
            loadExistingTransaction()
        } else {
            updateDateViews()
        }
        
        updateCategoryLabel()
        transactionAmountTxtField.delegate = self
        transactionAmountTxtField.placeholder = updateAmount()
        transactionDateFormat()
        createKeyboardDoneButton()
        tableView.separatorColor = CustomColors.greenColor
    }
    
    func loadExistingTransaction() {
        ProgressHUD.animate("Loading Transaction", .barSweepToggle)
        guard let transaction = transactionToEdit else { return }
        
        transactionReferenceTxtField.text = transaction.reference
        transactionAmountTxtField.text = transaction.amount.formatted(.currency(code: "NZD"))
        transactionDateLabel.text = transaction.date?.formatted(date: .numeric, time: .omitted)
        
        transactionComments.text = transaction.comments
        if let type = TransactionType(rawValue: transaction.transactionType!) {
            if type == .income {
                transactionTypeSegmentedControl.selectedSegmentIndex = 0
                transactionType = income
            } else if type == .expense {
                transactionTypeSegmentedControl.selectedSegmentIndex = 1
                transactionType = expense
            }
        }
        updateCategoryLabel()
        ProgressHUD.dismiss()
    }
    
    func transactionDateFormat() {
        let midnightToday = Calendar.current.startOfDay(for: Date())
        transactionDatePicker.maximumDate = midnightToday
        transactionDatePicker.date = midnightToday
    }
    
    func updateDateViews() {
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .short
        
        transactionDateLabel.text = dateFormater.string(from: transactionDatePicker.date)
    }
    
    func checkFields() -> (transactionReference: String, transactionAmount: Double, transactionDate: Date)? {
        
        guard let transactionReference = transactionReferenceTxtField.text, !transactionReference.isEmpty,
              let transactionAmount = transactionAmountTxtField.text, !transactionAmount.isEmpty,
              let transactionDate = transactionDateLabel.text, !transactionDate.isEmpty else {
            ProgressHUD.failed(ErrorMessageType.emptyForm.message())
            return nil
        }
        let formattedAmount = formatTransactionAmount(transactionAmount: transactionAmount)
        let formattedDate = formatTransactionDate(transactionDate: transactionDate)
        
        return (transactionReference, formattedAmount, formattedDate)
    }
    
    func formatTransactionAmount(transactionAmount: String) -> Double {
        
        let formattedNumber = transactionAmount.components(separatedBy: .decimalDigits.inverted).joined()
        let amount = (Double(formattedNumber) ?? 0) / Double(100)
        return amount
    }
    
    func formatTransactionDate(transactionDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short

        let date = dateFormatter.date(from: transactionDate)!
        return date
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        ProgressHUD.animate("Creating Transaction", .barSweepToggle)
        
        guard let fields = checkFields() else { return }
        guard let categoryID = category?.categoryID else {
            ProgressHUD.failed("Please select one category")
            return
        }
        guard let wallet = wallet else {
            ProgressHUD.failed("Failed creating transaction")
            return
        }
        
        var transaction: Transaction!
        
        if transactionToEdit != nil{
            transaction = transactionToEdit
            transaction.isModified = true
        } else {
            transaction = Transaction(context: manager.context)
            transaction.isModified = false
        }
        
        transaction.reference = fields.transactionReference
        transaction.amount = fields.transactionAmount
        transaction.date = fields.transactionDate
        transaction.comments = transactionComments.text ?? ""
        transaction.transactionType = transactionType
        transaction.wallet = wallet
        transaction.categoryID = Int32(categoryID)

        manager.saveContext()
        
        let sucessMessage = transactionToEdit != nil ? "Transaction updated" : "Transaction created"
        ProgressHUD.succeed(sucessMessage)
        
        //Analytics
        setUserProperty(for: transaction.amount)
        logTransactionEvent(amount: transaction.amount, type: transactionType, category: category?.categoryName, edit: transaction.isModified)
        logCategoryEvent(category: category?.categoryName)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.inputTransactionDelegate?.didUpdateHomeView()
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        resetFields()
    }
    
    //reset the fields after a transaction is created or updated
    func resetFields() {
        transactionAmountTxtField.text = ""
        transactionReferenceTxtField.text = ""
        transactionComments.text = ""
        categoryName.text = "Not Set"
        categoryImage.image = UIImage(systemName: "questionmark.circle")
        transactionTypeSegmentedControl.selectedSegmentIndex = 0
        transactionType = income
        transactionDateFormat()
        updateDateViews()
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
    }
    
    @IBAction func transactionTypeSegmentedChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            transactionType = income
        } else if sender.selectedSegmentIndex == 1 {
            transactionType = expense
        }
    }
    
    func updateCategoryLabel(){
        if let category = category {
            categoryName.text = category.categoryName
            categoryImage.image = UIImage(systemName: category.iconName)
            categoryImage.setImageColor(color: UIColor(hexaRGB: category.color, alpha: 1.0) ?? .black)
        } else {
            categoryName.text = "Not Set"
            categoryImage.image = UIImage(systemName: "questionmark.circle")
        }
        tableView.reloadData()
    }
    
    //MARK: - Delegate Methods
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch (indexPath.section, indexPath.row) {
            case(transactionDateIndexPath.section, transactionDateIndexPath.row): if isTransactionDatePickerShown {
                return 216.0
            } else {
                return 0.0
            }
            case (buttonSection.section, buttonSection.row) :
                return 60
            default:
                return 50
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section, indexPath.row) {
            case (transactionDateIndexPath.section, transactionDateIndexPath.row - 1): if isTransactionDatePickerShown {
                isTransactionDatePickerShown = false
            } else {
                isTransactionDatePickerShown = true
            }
                tableView.beginUpdates()
                tableView.endUpdates()
            default:
                break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.categorySelection {
            let destinationVC = segue.destination as? SelectCategoryViewController
            destinationVC?.delegate = self
            destinationVC?.selectedCategory = category
        }
    }
}

//MARK: - Create the done Button
extension InputTransactionTableViewController {
    func createKeyboardDoneButton() {
        let uiViews: [UIView] = [transactionReferenceTxtField, transactionAmountTxtField, transactionComments]
        
        UIViewController.addDoneButtonOnKeyboard(for: uiViews, target: self, selector: #selector(doneButtonAction))
    }
    
    @objc func doneButtonAction(){
        view.endEditing(true)
    }
}

//MARK: - TextField Delegate
extension InputTransactionTableViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let digit = Int(string) {
            amount = amount * 10 + digit
            
            if amount > 1_000_000_000_00 {
                ProgressHUD.failed("Please enter amount less than 1 Billion")
                transactionAmountTxtField.text = ""
                amount = 0
            } else {
                transactionAmountTxtField.text = updateAmount()
            }
        }
        
        if string == "" {
            amount = amount/10
            transactionAmountTxtField.text = amount == 0 ? "" : updateAmount()
        }
        
        return false
    }
    
    func updateAmount() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        let amount = Double(amount/100) + Double(amount%100)/100
        return formatter.string(from: NSNumber(value: amount))
    }
}

//MARK: - Protocols
extension InputTransactionTableViewController: SelectCategoryDelegate {   
    func didSelect(category: CategoryElement) {
        self.category = category
        updateCategoryLabel()
    }
}

//MARK: - Analytics
extension InputTransactionTableViewController {
    func setUserProperty(for transactionAmount: Double) {
        var amountRange: String
        
        switch transactionAmount {
            case 0..<50:
                amountRange = "0-49"
            case 50..<100:
                amountRange = "50-99"
            case 100..<500:
                amountRange = "100-499"
            case 500..<1000:
                amountRange = "500-999"
            case 1000..<5000:
                amountRange = "1000-4999"
            case 5000..<10000:
                amountRange = "5000-9999"
            default:
                amountRange = "10000+"
        }
        
        Analytics.setUserProperty(amountRange, forName: A.transactionAmountRange)
    }
    
    func logTransactionEvent(amount: Double, type: String, category: String?, edit: Bool) {
        Analytics.logEvent(A.transaction, parameters: [
            A.transactionAmount: amount,
            A.transactionType: type,
            A.transactionCategory: category ?? "",
            A.isTransactionModified : edit ? 1 : 0
        ])
    }
    
    func logCategoryEvent(category: String?) {
        Analytics.logEvent(A.selectedCategory, parameters: [A.transactionCategory : category ?? ""])
    }
    
}
