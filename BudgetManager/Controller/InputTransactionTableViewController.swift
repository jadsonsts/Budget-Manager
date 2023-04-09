//
//  InputTransactionTableViewController.swift
//  BudgetManager
//
//  Created by Jadson on 12/02/23.
//

import UIKit

class InputTransactionTableViewController: UITableViewController {
    
    
    @IBOutlet weak var transactionTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var transactionReferenceTxtField: UITextField!
    @IBOutlet weak var transactionAmountTxtField: UITextField!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var transactionDate: UIDatePicker!
    @IBOutlet weak var transactionComments: UITextView!
    
    let buttonSection = IndexPath(row: 0, section: 7)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        transactionReferenceTxtField.delegate = self
        transactionAmountTxtField.delegate = self
        transactionDateFormart()
        tableView.separatorColor = CustomColors.greenColor
//        addDoneButtonOnKeyboard()
        createKeyboardDoneButton()
        

    }
    
    func transactionDateFormart() {
        let midnightToday = Calendar.current.startOfDay(for: Date())
        transactionDate.maximumDate = midnightToday
        transactionDate.date = midnightToday
    }
    
    func createKeyboardDoneButton() {
        let uiViews: [UIView] = [transactionReferenceTxtField, transactionAmountTxtField, transactionComments]
        
        UIViewController.addDoneButtonOnKeyboard(for: uiViews, target: self, selector: #selector(doneButtonAction))
    }
    
    @objc func doneButtonAction(){
        view.endEditing(true)
    }

    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == buttonSection.section {
            return 60
        } else {
            return 50
            }
    }
    
    // MARK: - Table view data source
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.categorySelection {
            let destinationVC = segue.destination as? CategoriesCollectionViewController
           // destinationVC?.delegate = self
        }
    }

}


extension InputTransactionTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        transactionReferenceTxtField.endEditing(true)
        transactionAmountTxtField.endEditing(true)
        
        if textField == transactionReferenceTxtField {
            textField.resignFirstResponder()
            transactionAmountTxtField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
