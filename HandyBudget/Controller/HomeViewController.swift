//
//  HomeViewController.swift
//  Handy Budget - Expense Tracker
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FirebaseFirestore
import FirebaseAnalytics
import ProgressHUD
import CoreData

class HomeViewController: UIViewController {
    
    let manager = CoreDataStack.shared
    var user: NSFetchedResultsController<User>?
    var wallet: NSFetchedResultsController<Wallet>?
    var transaction: NSFetchedResultsController<Transaction>?
    
    var transactionSections = [Section]()
    
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
        fetchUser()
        configureSegmentedController()
        createKeyboardDoneButton()
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
    
    
    func createUserCoreData(userID: String) {
        
        DataController.shared.getUserDataOnFirebase(uid: userID) { [weak self] data in
            guard let self else { return }
            let user = User(context: self.manager.context)
            
            user.name = data.name
            user.email = data.email
            user.firebase_ID = data.userID
            
            self.manager.saveContext()
            
            self.createUserWalletCoreData(user: user)
            
        } onError: { errorMessage in
            ProgressHUD.failed("Whoops, Something went wrong!")
        }
    }
    
    func createUserWalletCoreData(user: User) {
        let wallet = Wallet(context: manager.context)
        //create wallet object
        wallet.name = "Main"
        wallet.amount = 0.0
        wallet.user = user
        
        manager.saveContext()
        
        fetchUser()
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
    
    @IBAction func newTransactionPressed(_ sender: Any) {
        Analytics.logEvent(A.newTransaction, parameters: nil)
    }
    
    @IBAction func transactionSegmentedControlDidChange(_ sender: CustomSegmentedControl) {
        transactionsSegmentedControl.underlinePosition()
        searchTransaction.text = ""
        fetchTransactionsByTransactionType()
    }
    
    func formatDateToString(transactionDate: Date) -> String {
        let date  = transactionDate.formatted(Date.FormatStyle()
            .weekday(.abbreviated)
            .day(.twoDigits)
            .month(.abbreviated)
            .year(.defaultDigits))
        return date
    }
    
    //unwind when editing transaction
    @IBAction func unwindToPreviousPage(_ segue: UIStoryboardSegue) {
        
    }
    
    //MARK: - organising transactions into sections by date
    
    func organiseTransactionsByDate() {
        ProgressHUD.animate("Loading Transactions", .barSweepToggle)
        
        transactionSections = []
        guard let transactions = transaction?.fetchedObjects else { return }
        
        let transactionDictionary: [Date: [Transaction]] = Dictionary(grouping: transactions) { $0.date ?? Date() }
        
        for (date, transactions) in transactionDictionary {
            transactionSections.append(Section(date: date, transaction: transactions))
        }
        transactionSections.sort { $0.date > $1.date }
        
        DispatchQueue.main.async {
            self.transactionsTableView.reloadData()
            self.transactionsTableView.isHidden = false
        }
        ProgressHUD.dismiss()
    }
}

extension HomeViewController: NSFetchedResultsControllerDelegate {
    
    func fetchUser() {
        ProgressHUD.animate("Loading User Data", .barSweepToggle)
        guard let id = Auth.auth().currentUser?.uid else { return }
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "firebase_ID == %@", id)
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: manager.context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = self
        self.user = controller
        
        do {
            try controller.performFetch()
        } catch _ {
            ProgressHUD.failed("Error fetching the user")
        }
        
        if user?.fetchedObjects?.isEmpty ?? true {
            createUserCoreData(userID: id)
        } else {
            beginUIUpdate(firebaseID: id)
        }
    }
    
    //idk if this name is enough... many different instructions(?)
    func beginUIUpdate(firebaseID: String) {
        DispatchQueue.main.async {
            let userName = self.user?.fetchedObjects?.first?.name
            self.userNameLabel.text = ("Hello, \(userName ?? "Test")")
            Analytics.setUserID(firebaseID)
            Analytics.setUserProperty(userName, forName: A.userName)
            self.fetchUserProfilePicture()
            self.fetchWallet()
        }
    }
    
    func fetchWallet() {
        ProgressHUD.animate("Loading Wallet Data", .barSweepToggle)
        guard let user = user?.fetchedObjects?.first else { return }
        let fetchRequest: NSFetchRequest<Wallet> = Wallet.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: manager.context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        
        controller.delegate = self
        self.wallet = controller
        do {
            try controller.performFetch()
        } catch let error {
            ProgressHUD.failed("Error loading the wallet\n \(error)")
        }
        if let walletAmount = wallet?.fetchedObjects?.first?.calculateAmount() {
            loadWalletLabel(walletAmount: walletAmount)
        }
        ProgressHUD.dismiss()
        
        fetchTransactionsByTransactionType()
    }
    
    func fetchTransactions(with request: NSFetchRequest<Transaction> = Transaction.fetchRequest()) {
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: manager.context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        
        controller.delegate = self
        self.transaction = controller
        
        do {
            try controller.performFetch()
        } catch let error {
            ProgressHUD.failed("Whoops! something went wrong \(error)")
        }
        organiseTransactionsByDate()
    }
    
    func fetchTransactionsByTransactionType() {
        ProgressHUD.animate("Loading Transactions", .barSweepToggle)
        
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let allTransactions = NSSortDescriptor(key: "date", ascending: true)
        guard let wallet = wallet?.fetchedObjects?.first else { return }
        
        switch transactionsSegmentedControl.selectedSegmentIndex {
            case 0:
                fetchRequest.sortDescriptors = [allTransactions]
                fetchRequest.predicate = NSPredicate(format: "wallet == %@", wallet)
            case 1:
                let filterByIncome = NSPredicate(format: "wallet == %@ AND transactionType == %@", wallet, "income")
                fetchRequest.predicate = filterByIncome
                fetchRequest.sortDescriptors = [allTransactions]
            case 2:
                let filterByExppense = NSPredicate(format: "wallet == %@ AND transactionType == %@", wallet, "expense")
                fetchRequest.predicate = filterByExppense
                fetchRequest.sortDescriptors = [allTransactions]
            default:
                fetchRequest.sortDescriptors = [allTransactions]
                fetchRequest.predicate = NSPredicate(format: "wallet == %@", wallet)
        }
        
        fetchTransactions(with: fetchRequest)
    }
}

//MARK: - TableView - Delegate and DataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if transactionSections.isEmpty {
            return 1
        } else {
            return transactionSections.count
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if transactionSections.isEmpty {
            return ""
        } else {
            let sectionDate = transactionSections[section].date
            return formatDateToString(transactionDate: sectionDate)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if transactionSections.isEmpty {
            return 1
        } else {
            let sectionData = transactionSections[section]
            return sectionData.transaction.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if transactionSections.isEmpty {
            return transactionsTableView.bounds.height
        } else {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !transactionSections.isEmpty {
            if let cell = tableView.dequeueReusableCell(withIdentifier: K.transactionCell, for: indexPath) as? TransactionsTableViewCell {
                let sectionData = transactionSections[indexPath.section]
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
        
        guard indexPath.section < transactionSections.count else { return } // Invalid section index
        
        let section = transactionSections[indexPath.section]
        
        guard indexPath.row < section.transaction.count else { return } // Invalid row index
        selectedTransaction = section.transaction[indexPath.row]
        
        performSegue(withIdentifier: K.detailSegue, sender: selectedTransaction)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.detailSegue {
            if let transacionDetailsVC = segue.destination as? TransactionDetailedViewController,
               let transaction = sender as? Transaction {
                transacionDetailsVC.transaction = transaction
                transacionDetailsVC.wallet = wallet?.fetchedObjects?.first
                transacionDetailsVC.updateTransactionDelegate = self
            }
        } else if segue.identifier == K.newTransaction {
            if let transactionInputVC = segue.destination as? InputTransactionTableViewController {
                if let wallet = wallet?.fetchedObjects?.first {
                    transactionInputVC.wallet = wallet
                    transactionInputVC.inputTransactionDelegate = self
                } else {
                    print("nao ta passando") //put some error msg
                }
            }
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    
    //Gets predicate to filter when the user types based on the selected index
    func getPredicate(for segmentIndex: Int, searchText: String) -> NSPredicate {
        switch segmentIndex {
            case 0: //all (income and expense)
                return NSPredicate(format: "reference CONTAINS[cd] %@ OR comments CONTAINS[cd] %@ OR amount == %@", searchText, searchText, NSNumber(value: Double(searchText) ?? 0))
            case 1: //income
                return NSPredicate(format: "reference CONTAINS[cd] %@ OR comments CONTAINS[cd] %@ OR amount == %@ AND transactionType == %@", searchText, searchText, NSNumber(value: Double(searchText) ?? 0), "income")
            case 2: //expense
                return NSPredicate(format: "reference CONTAINS[cd] %@ OR comments CONTAINS[cd] %@ OR amount == %@ AND transactionType == %@", searchText, searchText, NSNumber(value: Double(searchText) ?? 0), "expense")
            default: //all (income and expense)
                return NSPredicate(format: "reference CONTAINS[cd] %@ OR comments CONTAINS[cd] %@ OR amount == %@", searchText, searchText, NSNumber(value: Double(searchText) ?? 0))
        }
    }
    //prepare the request when the user searches
    func getFetchRequest(with predicate: NSPredicate) -> NSFetchRequest<Transaction> {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let allTransactions = NSSortDescriptor(key: "date", ascending: true)
        request.predicate = predicate
        request.sortDescriptors = [allTransactions]
        if let wallet = wallet?.fetchedObjects?.first {
            let walletFilter = NSPredicate(format: "wallet == %@", wallet)
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [walletFilter, predicate])
            request.predicate = compoundPredicate
        } else {
            request.predicate = predicate
        }
        return request
    }
    
    //combine the predicate and the fecth request to send it through and filter the transactions accordingly
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let textSearchBar = searchBar.text, !textSearchBar.isEmpty {
            let transactionPredicate = getPredicate(for: transactionsSegmentedControl.selectedSegmentIndex, searchText: textSearchBar)
            let fetchRequest = getFetchRequest(with: transactionPredicate)
            fetchTransactions(with: fetchRequest)
        } else {
            searchBar.resignFirstResponder()
        }
        Analytics.logEvent(A.searchPressed, parameters: [A.searchText: searchBar.text as Any])
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchTransactionsByTransactionType()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    //hide keyboard when user deletes all the text
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}

//MARK: - UPDATE VIEW DELEGATE METHOD
extension HomeViewController: InputTransactionDelegate {
    func didUpdateHomeView() {
        fetchWallet()
    }
}

//MARK: - DONE BUTTON CREATION
extension HomeViewController {
    func createKeyboardDoneButton() {
        let textFields: [UITextField] = [searchTransaction.searchTextField]
        
        UIViewController.addDoneButtonOnKeyboard(for: textFields, target: self, selector: #selector(doneButtonAction))
    }
    
    @objc func doneButtonAction(){
        view.endEditing(true)
    }
}

