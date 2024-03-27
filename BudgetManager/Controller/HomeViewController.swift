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
    
    var customer: Customer?
    var wallet: Wallet?
    var transactionDataSource = [Section]()
    var filteredDataSource = [Section]()
    var isSearching = false // Track whether search is active or not
    
    @IBOutlet weak var profilePictureUIImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var walletAmountLabel: UILabel!
    @IBOutlet weak var transactionsSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var hideValuesButton: UIButton!
    @IBOutlet weak var searchTransaction: UISearchBar!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideValuesButton.isHidden = true
        fetchUserData()
        fetchUserProfilePicture()
        configureSegmentedController()
        searchTransaction.delegate = self
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.separatorColor = CustomColors.greenColor
        transactionsTableView.isHidden = true //hide the tableview at the beggining
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        searchTransaction.clipsToBounds = true
    }
    
    func configureSegmentedController() {
        self.transactionsSegmentedControl.frame = CGRect(
            x: self.transactionsSegmentedControl.frame.minX,
            y: self.transactionsSegmentedControl.frame.minY,
            width: transactionsSegmentedControl.frame.width,
            height: 0.5)
        transactionsSegmentedControl.hightlightSelectedSegment()
        self.transactionsSegmentedControl.clipsToBounds = true
    }
    
    func loadWalletLabel(walletAmount: Double) {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        walletAmountLabel.text = formatter.string(for: walletAmount)
    }
    
    func fetchUserProfilePicture() {
        
        profilePictureUIImage.layer.cornerRadius = 25
        profilePictureUIImage.clipsToBounds = true
        DataController.shared.loadPhoto { [weak self] customerImage in
            //safeImage is the check from userDefaults, if there's no image, the app will check on firebase
            if let safeImage = customerImage {
                self?.profilePictureUIImage.image = safeImage
            } else {
                DataController.shared.downloadPhotoFromFirebase { [weak self] userProfilePicture in
                    self?.profilePictureUIImage.image = userProfilePicture
                }
            }
        }
    }
    
    func fetchUserData() {
        ProgressHUD.animate("Loading User Data", .barSweepToggle)
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        DataController.shared.fetchCustomer(userID) { [weak self] customer in
            self?.userNameLabel.text = "Hello, \(customer.name)"
            self?.customer = customer
            self?.fetchWallet()
            
        } onError: { errorMessage in
            ProgressHUD.failed(errorMessage)
        }
    }
    
    func fetchWallet() {
        guard let customerId = customer?.id else { return }
        ProgressHUD.animate("Loading Wallet Amount", .barSweepToggle)
        
        DataController.shared.fetchUserWallet(for: customerId) { [weak self] wallet in
            self?.wallet = wallet
            self?.loadWalletLabel(walletAmount: wallet.amount)
            
            if let walletID = wallet.walletID {
                self?.fetchTransactions(walletID: walletID)
            }
            
        } onError: { errorMessage in
            ProgressHUD.failed(errorMessage)
        }
    }
    
    @IBAction func newTransactionPressed(_ sender: Any) {
       // performSegue(withIdentifier: K.newTransaction, sender: self)
    }
    
    @IBAction func transactionSegmentedControlDidChange(_ sender: CustomSegmentedControl) {
        transactionsSegmentedControl.underlinePosition()
        searchTransaction.text = ""
        isSearching = false
        
        guard let walletID = wallet?.walletID else { return }
        
        switch sender.selectedSegmentIndex {
            case 0:
                fetchTransactions(walletID: walletID)
            case 1:
                fetchTransactions(type: 1, walletID: walletID)
            case 2:
                fetchTransactions(type: 2, walletID: walletID)
            default:
                fetchTransactions(walletID: walletID)
        }
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
    
    //unwind when editing transaction
    @IBAction func unwindToPreviousPage(_ segue: UIStoryboardSegue) {
        
    }
    
//MARK: - fetching data and creating sections by date
    func fetchTransactions(type: Int = 0, walletID: Int) {
        
        ProgressHUD.animate("Loading Transactions", .barSweepToggle)

        DataController.shared.fetchTransactions(type: type, walletID: walletID) { [weak self] transactions in
            
            //reset the object responsible for organising the transactions
            self?.transactionDataSource = []
            
            //sort the transactions by date in descending order
            let sortedTransactions = transactions.sorted { $0.date > $1.date }
            
            for transaction in sortedTransactions {
                guard let self = self else { return }
                if !self.transactionDataSource.contains(where: {$0.date == transaction.date}) {
                    self.transactionDataSource.append(Section(date: transaction.date, transaction: [transaction]))
                    
                } else {
                    guard let index = self.transactionDataSource.firstIndex(where: { $0.date == transaction.date}) else { return }
                    self.transactionDataSource[index].transaction.append(transaction)
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.transactionsTableView.reloadData()
                self?.transactionsTableView.isHidden = false
            }
            ProgressHUD.dismiss()
        } onError: { error in
            ProgressHUD.failed(error)
        }
    }
}

//MARK: - TableView - Delegate and DataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if transactionDataSource.isEmpty {
            return 1
        } else {
            return isSearching ? filteredDataSource.count : transactionDataSource.count
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if transactionDataSource.isEmpty {
            return ""
        } else {
            let sectionDate = isSearching ? filteredDataSource[section].date : transactionDataSource[section].date
            return formatDateString(dateString: sectionDate)
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactionDataSource.isEmpty {
            return 1
        } else {
            let sectionData = isSearching ? filteredDataSource[section] : transactionDataSource[section]
            return sectionData.transaction.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if transactionDataSource.isEmpty {
            return transactionsTableView.bounds.height
        } else {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !transactionDataSource.isEmpty {
            if let cell = tableView.dequeueReusableCell(withIdentifier: K.transactionCell, for: indexPath) as? TransactionsTableViewCell {
                let sectionData = isSearching ? filteredDataSource[indexPath.section] : transactionDataSource[indexPath.section]
                let transaction = sectionData.transaction[indexPath.row]
                cell.updateViews(transaction: transaction)
                return cell
            }
        } else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.textColor = .systemGray
            cell.textLabel?.font = UIFont(name: "Avenir Book", size: 20)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "No Transactions Yet\nInput your first transaction"
            cell.textLabel?.textAlignment = .center
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedTransaction: Transaction
        
        if isSearching {
            guard indexPath.section < filteredDataSource.count else {
                return // Invalid section index
            }
            
            let section = filteredDataSource[indexPath.section]
            guard indexPath.row < section.transaction.count else {
                return // Invalid row index
            }
            
            selectedTransaction = section.transaction[indexPath.row]
        } else {
            guard indexPath.section < transactionDataSource.count else {
                return // Invalid section index
            }
            
            let section = transactionDataSource[indexPath.section]
            guard indexPath.row < section.transaction.count else {
                return // Invalid row index
            }
            
            selectedTransaction = section.transaction[indexPath.row]
        }

        performSegue(withIdentifier: K.detailSegue, sender: selectedTransaction)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let transacionDetailsVC = segue.destination as? TransactionDetailedViewController, let transaction = sender as? Transaction {
            transacionDetailsVC.transaction = transaction
            transacionDetailsVC.wallet = wallet
            transacionDetailsVC.updateTransactionDelegate = self
        } else if let transactionInputVC = segue.destination as? InputTransactionTableViewController {
            transactionInputVC.inputTransactionDelegate = self
            transactionInputVC.wallet = wallet
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchBarText = searchBar.text else { return }
        
        if searchBarText.isEmpty {
            // Clear the filteredDataSource when search text is empty
            filteredDataSource = []
            isSearching = false
        } else {
                // Filter the transactions within each section based on the search text
                filteredDataSource = transactionDataSource.map { section in
                    let filteredTransactions = section.transaction.filter { transaction in
                        let referenceMatch = transaction.reference.localizedCaseInsensitiveContains(searchBarText)
                        let amountMatch = transaction.amount.description.localizedCaseInsensitiveContains(searchBarText)
                        
                        return referenceMatch || amountMatch
                    }
                    return Section(date: section.date, transaction: filteredTransactions)
                }.filter { section in
                    return !section.transaction.isEmpty
                }
            isSearching = true
        }
        transactionsTableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredDataSource = []
            isSearching = false
            transactionsTableView.reloadData()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

//MARK: - UPDATE VIEW DELEGATE METHOD
extension HomeViewController: InputTransactionDelegate {
    func didUpdateHomeView() {
        fetchWallet()
    }
}
