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
        ProgressHUD.show()
        ProgressHUD.colorAnimation = CustomColors.greenColor
        hideValuesButton.isHidden = true
        
        loadPicture()
        loadData()
        configureSegmentedController()
        searchTransaction.delegate = self
        transactionsTableView.delegate = self
        transactionsTableView.dataSource = self
        transactionsTableView.rowHeight = 60
        transactionsTableView.separatorColor = CustomColors.greenColor
        
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
    
    func loadLabels() {
        
        guard let customerName = customer?.name, let walletAmount = wallet?.amount else { return }
        userNameLabel.text = "Hello, \(customerName)"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        walletAmountLabel.text = formatter.string(for: walletAmount)
    }
    
    func loadPicture() {
        profilePictureUIImage.layer.cornerRadius = 25
        profilePictureUIImage.clipsToBounds = true
        DataController.shared.loadPhoto { [weak self] customerImage in
            if let safeImage = customerImage {
                self?.profilePictureUIImage.image = safeImage
            } else {
                self?.profilePictureUIImage.image = UIImage(systemName: "person.fill")
            }
        }
    }
    
    func loadData() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        DataController.shared.fetchCustomer(userID) { [weak self] customer in
            self?.customer = customer
            self?.fetchWallet()
            
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }

    }
    
    func fetchWallet() {
        guard let customerId = customer?.id else { return }
        
        DataController.shared.fetchUserWallet(for: customerId) { [weak self] wallet in
            self?.wallet = wallet
            self?.loadLabels()
            
            if let walletID = wallet.walletID {
                self?.fetchTransactions(walletID: walletID)
            }
            
        } onError: { errorMessage in
            ProgressHUD.showError(errorMessage)
        }
    }
    
    @IBAction func newTransactionPressed(_ sender: Any) {
       // performSegue(withIdentifier: K.newTransaction, sender: self)
    }
    
    @IBAction func transactionSegmentedControlDidChange(_ sender: CustomSegmentedControl) {
        transactionsSegmentedControl.underlinePosition()
        
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
        ProgressHUD.show()

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
            }
            ProgressHUD.dismiss()
        } onError: { error in
            ProgressHUD.showError(error)
        }
    }
}

//MARK: - TableView - Delegate and DataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSearching ? filteredDataSource.count : transactionDataSource.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionDate = isSearching ? filteredDataSource[section].date : transactionDataSource[section].date
        return formatDateString(dateString: sectionDate)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionData = isSearching ? filteredDataSource[section] : transactionDataSource[section]
        
        return sectionData.transaction.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: K.transactionCell, for: indexPath) as? TransactionsTableViewCell {
            //let transaction = transactionDataSource[indexPath.section].transaction[indexPath.row]
            let sectionData = isSearching ? filteredDataSource[indexPath.section] : transactionDataSource[indexPath.section]
            let transaction = sectionData.transaction[indexPath.row]
            
            cell.updateViews(transaction: transaction)
            return cell
        } else {
            return TransactionsTableViewCell()
        }
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
        if let destinationVC = segue.destination as? TransactionDetailedViewController, let transaction = sender as? Transaction {
            destinationVC.transaction = transaction
            destinationVC.wallet = wallet
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
        loadData()
    }
}
