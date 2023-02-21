//
//  HomeViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    //let customer = Customer()

    @IBOutlet weak var profilePictureUIImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var walletAmountLabel: UILabel!
    @IBOutlet weak var transactionsSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var hideValuesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.rowHeight = 30
        
        navigationItem.hidesBackButton = true
        loadTransactions()

        self.transactionsSegmentedControl.frame = CGRect(x: self.transactionsSegmentedControl.frame.minX, y: self.transactionsSegmentedControl.frame.minY, width: transactionsSegmentedControl.frame.width, height: 50)
        transactionsSegmentedControl.hightlightSelectedSegment()
        
       
}
    
    @IBAction func hideValuesButton(_ sender: Any) {
        
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func transactionSegmentedControlDidChange(_ sender: Any) {
        transactionsSegmentedControl.underlinePosition()
    }
    
    func loadTransactions() {
        
    }

}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section: \(section)"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: K.transactionCell, for: indexPath) as? TransactionsTableViewCell {
//            let transaction = DataService.instance.getCustomer().wallet.transactions[indexPath.row]
//            cell.updateViews(transaction: transaction)
            return cell
        } else {
            return TransactionsTableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
}
