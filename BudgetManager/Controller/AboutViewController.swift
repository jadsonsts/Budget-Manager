//
//  AboutViewController.swift
//  BudgetManager
//
//  Created by Jadson on 7/02/24.
//

import UIKit

class AboutViewController: UIViewController {

    
    @IBOutlet weak var feature1Label: UILabel!
    @IBOutlet weak var feature1Description: UILabel!
    
    @IBOutlet weak var feature2Label: UILabel!
    @IBOutlet weak var feature2Description: UILabel!
    
    @IBOutlet weak var feature3Label: UILabel!
    @IBOutlet weak var feature3Description: UILabel!
    
    @IBOutlet weak var feature4Label: UILabel!
    @IBOutlet weak var feature4Description: UILabel!
    
    @IBOutlet weak var bottomTextLabel: UILabel!
    
    let feature1Name = "Expense and Income Tracking:"
    let feature1Detail = "Keep a meticulous record of every penny you spend or earn. Budget Manager simplifies the process, making it convenient to log transactions on the go."
    
    let feature2Name = "Comprehensive Transaction Details:"
    let feature2Detail = "Dive into the specifics of each transaction effortlessly. View detailed information such as date, category, and notes to gain valuable insights into your financial habits."
    
    let feature3Name = "User-Friendly Interface:"
    let feature3Detail = "Our app is designed with you in mind. Navigate seamlessly through the user-friendly interface, ensuring a hassle-free experience for users of all levels."
    
    let feature4Name = "Custom Categories:"
    let feature4Detail = "Tailor your expense and income categories to match your unique financial landscape. Budget Manager adapts to your lifestyle, providing a personalized tracking experience."
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showText()
        
    }
    
    private func showText() {
        feature1Label.text = feature1Name
        feature2Label.text = feature2Name
        feature3Label.text = feature3Name
        feature4Label.text = feature4Name
        
        feature1Description.text = feature1Detail
        feature2Description.text = feature2Detail
        feature3Description.text = feature3Detail
        feature4Description.text = feature4Detail
        
        setBackGround(labels: [feature1Description, feature2Description, feature3Description, feature4Description])
        
        bottomTextLabel.text = "Much more on the go, keep your app up to date so you don't miss anything in the future."
        
        
    }
    
    func setBackGround (labels: [UILabel]) {
        for label in labels {
            label.backgroundColor = .systemGray6
        }
    }
    

}
