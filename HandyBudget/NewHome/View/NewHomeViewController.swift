//
//  NewHomeViewController.swift
//  HandyBudget
//
//  Created by Jadson on 26/08/2025.
//

import UIKit

class NewHomeViewController: UIViewController {
    
    private lazy var homeView: NewHomeView = {
        let view = NewHomeView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        
    }
    
    override func loadView() {
        self.view = homeView
        
    }

}
