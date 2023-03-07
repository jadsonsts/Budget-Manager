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
        addDoneButtonOnKeyboard()
        

    }
    
    func transactionDateFormart() {
        let midnightToday = Calendar.current.startOfDay(for: Date())
        transactionDate.maximumDate = midnightToday
        transactionDate.date = midnightToday
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
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        transactionReferenceTxtField.inputAccessoryView = doneToolbar
        transactionAmountTxtField.inputAccessoryView = doneToolbar
        transactionComments.inputAccessoryView = doneToolbar
        
    }
    
    @objc func doneButtonAction(){
        transactionAmountTxtField.resignFirstResponder()
        transactionReferenceTxtField.resignFirstResponder()
        transactionComments.resignFirstResponder()
    }
}
