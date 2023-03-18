//
//  HomeViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit
import FirebaseAuth

struct Section {
    let date: String
    var transaction: [Transactions]
}

class HomeViewController: UIViewController {
    
    //let customer = Customer()

    @IBOutlet weak var profilePictureUIImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var walletAmountLabel: UILabel!
    @IBOutlet weak var transactionsSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var hideValuesButton: UIButton!
    @IBOutlet weak var searchTransaction: UISearchBar!
    
    var dataSource = [Section]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesSearchBarWhenScrolling = false
        
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
        transactionsTableView.rowHeight = 55
        transactionsTableView.separatorColor = CustomColors.greenColor
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        fetchAllTransactions()

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
    
    //MARK: - fetching data - move later (?)
    func fetchAllTransactions() {
        if let path = Bundle.main.path(forResource: "CustomerExample", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let newResponse = try JSONDecoder().decode(Customer.self, from: data)
                //print (newResponse)
                
                //create sections
                newResponse.wallet.transactions.forEach({ transactions in
                    if !self.dataSource.contains(where: {$0.date == transactions.date}) {
                        self.dataSource.append(Section(date: transactions.date, transaction: [transactions]))
                        
                    } else {
                        guard let index = self.dataSource.firstIndex(where: { $0.date == transactions.date}) else { return }
                        self.dataSource[index].transaction.append(transactions)
                        }
                })
                
                DispatchQueue.main.async { [self] in
                    transactionsTableView.reloadData()
                }
                
            } catch let DecodingError.dataCorrupted(context) {
                print(context)
            } catch let DecodingError.keyNotFound(key, context) {
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.valueNotFound(value, context) {
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch let DecodingError.typeMismatch(type, context)  {
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
            } catch {
                print("error: ", error)
            }
        }
    }
    
    func fetchIncomeTransactions() {
        
    }
    
    func fetchExpenseTransactions() {
        
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
        if let destinationVC = segue.destination as? TransactionDetailedViewController, let transaction = sender as? Transactions {
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
