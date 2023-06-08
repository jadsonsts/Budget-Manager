//
//  InputTransactionTableViewController.swift
//  BudgetManager
//
//  Created by Jadson on 12/02/23.
//

import UIKit
import ProgressHUD

class InputTransactionTableViewController: UITableViewController {
    
    @IBOutlet weak var transactionTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var transactionReferenceTxtField: UITextField!
    @IBOutlet weak var transactionAmountTxtField: UITextField!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var transactionDatePicker: UIDatePicker!
    @IBOutlet weak var transactionComments: UITextView!
    @IBOutlet weak var transactionDateLabel: UILabel!
    
    //var wallet: Wallet?
    var category: CategoryElement?
    var transactionToEdit: Transaction?
    var transactionType = "income" //set as default (income)
    var amount = 0
    let buttonSection = IndexPath(row: 0, section: 7)
    let transactionDateIndexPath = IndexPath(row: 1, section: 5)

    var isTransactionDatePickerShown: Bool = false {
        didSet {
            transactionDatePicker.isHidden = !isTransactionDatePickerShown
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateCategoryLabel()
        transactionAmountTxtField.delegate = self
        transactionAmountTxtField.placeholder = updateAmount()
        transactionDateFormart()
        updateDateViews()
        tableView.separatorColor = CustomColors.greenColor
        createKeyboardDoneButton()
        
    }

    func transactionDateFormart() {
        let midnightToday = Calendar.current.startOfDay(for: Date())
        transactionDatePicker.maximumDate = midnightToday
        transactionDatePicker.date = midnightToday
    }
    
    func updateDateViews() {
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .short
        
        transactionDateLabel.text = dateFormater.string(from: transactionDatePicker.date)
    }
    
    func checkFields() -> (transactionReference: String, transactionAmount: String, transactionDate: String)? {
        
        guard let transactionReference = transactionReferenceTxtField.text, !transactionReference.isEmpty,
              var transactionAmount = transactionAmountTxtField.text, !transactionAmount.isEmpty,
              var transactionDate = transactionDateLabel.text, !transactionDate.isEmpty else {
            ProgressHUD.showError(ErrorMessageType.emptyForm.message())
            return nil
        }
        
        // Remove the first character if it's a dollar sign
        if transactionAmount.hasPrefix("$") {
            transactionAmount = String(transactionAmount.dropFirst())
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        
        if let date = dateFormatter.date(from: transactionDate) {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let formattedDate = dateFormatter.string(from: date)
            transactionDate = formattedDate
        }
        print(transactionDate, transactionAmount)
        return (transactionReference, transactionAmount, transactionDate)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        ProgressHUD.show()
        guard let fields = checkFields() else {
            print("deu ruim na validacao dos campos")
            return }
        guard let categoryID = category?.categoryID else {
            ProgressHUD.showError("Please select one category")
            return }
        guard let wallet = UserVariables.wallet  else {
            print("deu ruim na wallet")
            return }
        
        
        let transaction = Transaction(id: nil,
                                      reference: fields.transactionReference,
                                      amount: Double(fields.transactionAmount) ?? 0.0,
                                      date: fields.transactionDate,
                                      comment: transactionComments.text ?? "",
                                      transactionType: transactionType,
                                      walletID: wallet.walletID!,
                                      categoryID: categoryID)
        
        print (transaction)
        
        
        DataController.shared.createTransaction(transaction: transaction) { _ in
            ProgressHUD.showSuccess()
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }
        
        tabBarController?.selectedIndex = 0
    }
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
    }
    
    @IBAction func transactionTypeSegmentedChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            transactionType = "income"
        } else if sender.selectedSegmentIndex == 1 {
            transactionType = "expense"
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
            let destinationVC = segue.destination as? CategoriesCollectionViewController
            destinationVC?.delegate = self
            destinationVC?.selectedCategory = category
            ProgressHUD.show()
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
                ProgressHUD.showError("Please enter amount less than 1 Billion")
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
        formatter.numberStyle = NumberFormatter.Style.currency
        let amount = Double(amount/100) + Double(amount%100)/100
        return formatter.string(from: NSNumber(value: amount))
    }
}

//MARK: - Protocols
//extension InputTransactionTableViewController: WalletDelegate {
//    func didLoadWallet(wallet: Wallet) {
//        self.wallet = wallet
//        print ("this is the wallet object: \(wallet)")
//        tableView.reloadData()
//        updateWalletLabel()
//    }
//}

extension InputTransactionTableViewController: SelectCategoryDelegate {
    func didSelect(category: CategoryElement) {
        self.category = category
        updateCategoryLabel()
    }
}
