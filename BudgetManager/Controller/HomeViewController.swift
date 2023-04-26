//
//  HomeViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import ProgressHUD


class HomeViewController: UIViewController {
    
    var customer: Customer!
    var wallet: Wallet!
    var dataSource = [Section]()
    
    @IBOutlet weak var profilePictureUIImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var walletAmountLabel: UILabel!
    @IBOutlet weak var transactionsSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var hideValuesButton: UIButton!
    @IBOutlet weak var searchTransaction: UISearchBar!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        
        DataController.shared.fetchCustomer(customer.firebaseID) { customer in
            ProgressHUD.show("Fetching User Information")
            self.customer = customer
            
            if let customerID = customer.id {
                DataController.shared.fetchUserWallet(for: customerID) { wallet in
                    ProgressHUD.show("Fetching Wallet Information")
                    self.wallet = wallet
                    self.loadLabels()
                    if let walletID = wallet.walletID {
                        self.fetchAllTransactions(walletID: walletID)
                    }
                    ProgressHUD.dismiss()
                } onError: { errorMessage in
                    ProgressHUD.showError(errorMessage)
                }

            }
            
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTransaction.delegate = self
        
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.rowHeight = 60
        transactionsTableView.separatorColor = CustomColors.greenColor
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        

        self.transactionsSegmentedControl.frame = CGRect(x: self.transactionsSegmentedControl.frame.minX, y: self.transactionsSegmentedControl.frame.minY, width: transactionsSegmentedControl.frame.width, height: 50)
        transactionsSegmentedControl.hightlightSelectedSegment()
        
        loadPicture()
    }
    
    func loadLabels() {
        userNameLabel.text = "Hello, \(customer.name)"
        walletAmountLabel.text = String(format: "$%.2f", wallet.amount)
    }
    
    func loadPicture() {
        profilePictureUIImage.layer.cornerRadius = 25
        profilePictureUIImage.clipsToBounds = true
        DataController.shared.loadPhoto { customerImage in
            if let safeImage = customerImage {
                self.profilePictureUIImage.image = safeImage
            } else {
                self.profilePictureUIImage.image = UIImage(systemName: "person.fill")
            }
            
        }
    }
    
    @IBAction func hideValuesButton(_ sender: Any) {
        
    }
    
    
    @IBAction func logOutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            ProgressHUD.showError(signOutError as? String)
        }
    }
    
    @IBAction func transactionSegmentedControlDidChange(_ sender: CustomSegmentedControl) {
        transactionsSegmentedControl.underlinePosition()
       
        switch sender.selectedSegmentIndex {
            case 0:
                fetchTransactions(type: 0)
            case 1:
                fetchTransactions(type: 1)
            case 2:
                fetchTransactions(type: 2)
            default:
                fetchTransactions(type: 0)
        }
       
    }
    
//MARK: - fetching data and creating sections by date
    func fetchAllTransactions(type: Int = 0, walletID: Int) {
        
        DataController.shared.fetchTransactions(type: type, walletID: walletID) { transactions in
            for transaction in transactions {
                if !self.dataSource.contains(where: {$0.date == transaction.date}) {
                    self.dataSource.append(Section(date: transaction.date, transaction: [transaction]))
                    
                } else {
                    guard let index = self.dataSource.firstIndex(where: { $0.date == transaction.date}) else { return }
                    self.dataSource[index].transaction.append(transaction)
                }
            }

            DispatchQueue.main.async { [self] in
                transactionsTableView.reloadData()
            }
        } onError: { error in
            print(error)
        }
    }
    
    func fetchTransactions(type: Int = 0) {
        DataController.shared.fetchTransactions(type: type, walletID: 1) { transactions in //change wallet to be dinamic
            ProgressHUD.show()
            self.dataSource = self.createSections(transactions: transactions)
            ProgressHUD.dismiss()
        } onError: { error in
            ProgressHUD.showError(error)
        }
    }
    
    //organizing the transactions by date:
    func createSections(transactions: Transactions) -> [Section] {
        var transactionsByDate: [String: [Transaction]] = [:]
        for transaction in transactions {
            if var transactionsForDate = transactionsByDate[transaction.date] {
                transactionsForDate.append(transaction)
                transactionsByDate[transaction.date] = transactionsForDate
            } else {
                transactionsByDate[transaction.date] = [transaction]
            }
        }
        var sections: [Section] = []
        for (date, transactions) in transactionsByDate {
            sections.append(Section(date: date, transaction: transactions))
        }
        
        sections.sort { $0.date > $1.date }
        return sections
    }
}
//MARK: - TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].date
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].transaction.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: K.transactionCell, for: indexPath) as? TransactionsTableViewCell {
            let transaction = dataSource[indexPath.section].transaction[indexPath.row]
           //print(transaction.amount)
            cell.updateViews(transaction: transaction)
            return cell
        } else {
            return TransactionsTableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = dataSource[indexPath.section].transaction[indexPath.row]
        performSegue(withIdentifier: K.detailSegue, sender: transaction)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TransactionDetailedViewController, let transaction = sender as? Transaction {
            destinationVC.transaction = transaction
        }
        
    }
    
}

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        transactionsTableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            //func to fetch all transactions (check the segmented selected all, income, expense)
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
