//
//  HomeViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/23.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var profilePictureUIImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var walletAmountLabel: UILabel!
    @IBOutlet weak var transactionsSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var transactionsTableView: UITableView!
    @IBOutlet weak var hideValuesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.transactionsSegmentedControl.frame = CGRect(x: self.transactionsSegmentedControl.frame.minX, y: self.transactionsSegmentedControl.frame.minY, width: transactionsSegmentedControl.frame.width, height: 50)
        transactionsSegmentedControl.hightlightSelectedSegment()
        
       
}
    
    @IBAction func hideValuesButton(_ sender: Any) {
        
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
    }
    
    @IBAction func transactionSegmentedControlDidChange(_ sender: Any) {
        transactionsSegmentedControl.underlinePosition()
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
