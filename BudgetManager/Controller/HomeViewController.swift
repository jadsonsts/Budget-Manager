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

protocol CustomerDelegate {
    func didLoadCustomer(customer: Customer)
}

protocol WalletDelegate {
    func didLoadWallet(wallet: Wallet)
}

class HomeViewController: UIViewController {
    
    var customer: Customer?
    var wallet: Wallet?
    var userID: String?
    var dataSource = [Section]()
    
    //delegate protocol to use the customer and wallet objects on other screens
    var customerDelegate: CustomerDelegate?
    var walletDelegate: WalletDelegate?
    
    
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if customer == nil && wallet == nil {
            loadDada()
        }
        loadPicture()
        
        searchTransaction.delegate = self
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.rowHeight = 60
        transactionsTableView.separatorColor = CustomColors.greenColor
        
        self.tabBarController?.navigationItem.hidesBackButton = true

        self.transactionsSegmentedControl.frame = CGRect(x: self.transactionsSegmentedControl.frame.minX, y: self.transactionsSegmentedControl.frame.minY, width: transactionsSegmentedControl.frame.width, height: 50)
        transactionsSegmentedControl.hightlightSelectedSegment()

    }
    
    func loadLabels() {
        
        guard let customerName = customer?.name, let walletAmount = wallet?.amount else { return }
        userNameLabel.text = "Hello, \(customerName)"
        walletAmountLabel.text = String(format: "$%.2f", walletAmount)
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
    
    func loadDada() {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        DataController.shared.fetchCustomer(userID) { customer in
            ProgressHUD.show("Fetching User Information")
            self.customer = customer
            //self.customerDelegate?.didLoadCustomer(customer: customer)
            UserVariables.customer = customer
            
            if let customerID = customer.id {
                DataController.shared.fetchUserWallet(for: customerID) { wallet in
                    ProgressHUD.show("Fetching Wallet Information")
                    self.wallet = wallet
                    //self.walletDelegate?.didLoadWallet(wallet: wallet)
                    UserVariables.wallet = wallet
                    print(wallet)
                    self.loadLabels()
                    if let walletID = wallet.walletID {
                        self.fetchAllTransactions(walletID: walletID)
                    }
                    ProgressHUD.dismiss()
                } onError: { errorMessage in
                    ProgressHUD.showError(errorMessage)
                }
            }
            ProgressHUD.dismiss()
            
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    @IBAction func hideValuesButton(_ sender: Any) {
        
    }
    
    
    @IBAction func logOutPressed(_ sender: Any) {
        //try to signOut, and use the method on SceneDelegate to move to the login Controller (LoginWithAppsViewController)
        do {
            try Auth.auth().signOut()
//            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
//                sceneDelegate.checkAuthentication()
//            }
        } catch let signOutError as NSError {
            //print("Error signing out: %@", signOutError)
            ProgressHUD.showError(signOutError as? String)
        }
    }
    
    @IBAction func transactionSegmentedControlDidChange(_ sender: CustomSegmentedControl) {
        transactionsSegmentedControl.underlinePosition()
        
        guard let walletID = wallet?.walletID else { return }
       
        switch sender.selectedSegmentIndex {
            case 0:
                fetchAllTransactions(walletID: walletID)
            case 1:
                fetchAllTransactions(type: 1, walletID: walletID)
            case 2:
                fetchAllTransactions(type: 2, walletID: walletID)
            default:
                fetchAllTransactions(walletID: walletID)
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
            ProgressHUD.showError(error)
        }
    }
}

//MARK: - TableView - Delegate and DataSource
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

//extension HomeViewController: CustomerDelegate, WalletDelegate {
//    func didLoadCustomer(customer: Customer) {
//    }
//
//    func didLoadWallet(wallet: Wallet) {
//        //self.wallet = wallet
//    }
//}
