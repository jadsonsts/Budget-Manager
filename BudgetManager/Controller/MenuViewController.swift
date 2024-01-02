//
//  MenuViewController.swift
//  BudgetManager
//
//  Created by Jadson on 3/12/23.
//

import UIKit
import FirebaseAuth
import ProgressHUD

class MenuViewController: UIViewController {
    
    
    @IBOutlet weak var userSettingsButton: UIButton!
    @IBOutlet weak var walletsButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtonUI()
    }
    

    func setupButtonUI() {
        
        setupButton(userSettingsButton, title: "User Settings", imageName: "person.circle" , background: .clear)
        setupButton(walletsButton, title: "Wallets", imageName: "wallet.pass", background: .clear)
        setupButton(aboutButton, title: "About", imageName: "info.circle", background: .clear)
        setupButton(logoutButton, title: "Logout", imageName: "power.circle", background: .clear)
        
    }
    
    func setupButton(_ button: UIButton, title: String, imageName: String,  background: UIColor) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 22)
        button.setTitleColor(CustomColors.greenColor, for: .normal)
        button.setTitleColor(CustomColors.labelColor, for: .selected)
        button.backgroundColor = background
        if let image = UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate) {
            button.setImage(image, for: .normal)
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 12, left: -5, bottom: 12, right: 10)
        
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popViewController(animated: true)
        } catch let logoutError as NSError {
            ProgressHUD.showError(logoutError as? String)
        }
    }

}
